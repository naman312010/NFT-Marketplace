pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract escrow is ERC1155Holder, ReentrancyGuard {
    enum Stage {NOT_LISTED, LISTED, PARTIALLY_SOLD, ORDER_CLOSED}
    struct Order {
        Stage stage;
        uint256 id;
        address payable seller;
        uint256 tokenID;
        uint256 amountToSell;
        IERC1155 contractAddr;
        uint256 price;
    }
    using SafeMath for uint256;
    uint256 orderCtr;
    mapping(uint256 => Order) public ORDER;

    event TokenListed(
        address _seller,
        address _contract,
        uint256 _tokenIdListed,
        uint256 indexed _amountListed,
        uint256 _pricePerPiece
    );
    event TokenUnlisted(
        address _seller,
        address _contract,
        uint256 indexed _tokenIdUnlisted,
        uint256 _amountUnlisted
    );
    event TokenPurchased(
        address _seller,
        address _buyer,
        address _contract,
        uint256 indexed _tokenIdPurchased,
        uint256 _amountBought,
        uint256 _cost
    );

    function list(
        address _contract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price
    ) public {
        require(_contract != address(0), "Null contract address provided!!!");
        IERC1155 token = IERC1155(_contract);
        require(
            token.isApprovedForAll(msg.sender, address(this)) == true,
            "Token not approved for trade using this escrow!!!"
        );
        require(_amount > 0, "Amount to list not provided!!!");
        require(
            token.balanceOf(msg.sender, _tokenId) >= _amount,
            "Not enough tokens in your wallet!!!"
        );
        orderCtr++;
        ORDER[orderCtr] = Order(
            Stage.LISTED,
            orderCtr,
            payable(msg.sender),
            _tokenId,
            _amount,
            token,
            _price
        );
        token.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );
        emit TokenListed(msg.sender, _contract, _tokenId, _amount, _price);
    }

    function unlist(uint256 orderID) public {
        require(
            msg.sender == ORDER[orderID].seller,
            "Only seller can access this function!!!"
        );
        require(
            (orderID > 0) && (orderID <= orderCtr),
            "Invalid Order ID provided!!!"
        );
        require(
            ORDER[orderID].stage != Stage.ORDER_CLOSED,
            "Order is closed!!!"
        );
        require(
            ((ORDER[orderID].stage == Stage.LISTED) ||
                (ORDER[orderID].stage == Stage.PARTIALLY_SOLD)),
            "Wrong Token stage!!!"
        );
        ORDER[orderID].contractAddr.safeTransferFrom(
            address(this),
            ORDER[orderID].seller,
            ORDER[orderID].tokenID,
            ORDER[orderID].amountToSell,
            ""
        );
        emit TokenUnlisted(
            msg.sender,
            address(ORDER[orderID].contractAddr),
            ORDER[orderID].tokenID,
            ORDER[orderID].amountToSell
        );
        ORDER[orderID].amountToSell = 0;
        ORDER[orderID].stage = Stage.ORDER_CLOSED;
    }

    function buy(uint256 orderID, uint256 buyAmount) public payable {
        require(
            (orderID > 0) && (orderID <= orderCtr),
            "Invalid Order ID provided!!!"
        );
        require(
            ORDER[orderID].stage != Stage.ORDER_CLOSED,
            "Order is closed!!!"
        );
        require(
            msg.sender != ORDER[orderID].seller,
            "Sellers can't buy their own token!!!"
        );
        require(
            (buyAmount > 0) && (buyAmount <= ORDER[orderID].amountToSell),
            "Invalid buy amount provided!!!"
        );
        require(
            ((ORDER[orderID].stage == Stage.LISTED) ||
                (ORDER[orderID].stage == Stage.PARTIALLY_SOLD)),
            "Wrong Token stage!!!"
        );
        uint256 cost = (ORDER[orderID].price).mul(buyAmount);
        require(msg.value == cost, "Insufficient funds!!!");
        ORDER[orderID].contractAddr.safeTransferFrom(
            address(this),
            msg.sender,
            ORDER[orderID].tokenID,
            buyAmount,
            ""
        );
        ORDER[orderID].seller.transfer(cost);
        // ORDER[orderID].amountToSell -= buyAmount;
        ORDER[orderID].amountToSell = ORDER[orderID].amountToSell.sub(
            buyAmount
        );
        if (ORDER[orderID].amountToSell == 0)
            ORDER[orderID].stage = Stage.ORDER_CLOSED;
        else ORDER[orderID].stage = Stage.PARTIALLY_SOLD;
        emit TokenPurchased(
            ORDER[orderID].seller,
            msg.sender,
            address(ORDER[orderID].contractAddr),
            ORDER[orderID].tokenID,
            buyAmount,
            cost
        );
    }
}
