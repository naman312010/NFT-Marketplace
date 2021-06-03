pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract escrow is ERC1155Holder, ReentrancyGuard {
    enum Stage {NOT_LISTED, LISTED, SOLD}
    struct Order {
        uint256 id;
        address payable seller;
        uint256 tokenID;
        uint256 amount;
        IERC1155 contractAddr;
        uint256 price;
        Stage stage;
        address buyer;
    }
    using SafeMath for uint256;
    uint256 orderCtr;
    mapping(uint256 => Order) public ORDER;

    // event TokenPurchased(address _seller,address _buyer, uint256 _tokenIdPurchased, uint256 _tokenPurchased);
    // event SaleCancelled(address _seller);

    function list(
        address _contract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price
    ) public {
        orderCtr++;
        IERC1155 token = IERC1155(_contract);
        ORDER[orderCtr] = Order(
            orderCtr,
            payable(msg.sender),
            _tokenId,
            _amount,
            token,
            _price,
            Stage.LISTED,
            address(0)
        );
        token.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );
    }

    function buy(uint256 orderID, uint256 amt) public payable {
        require(ORDER[orderID].stage == Stage.LISTED, "Token not listed");
        uint256 cost = (ORDER[orderID].price).mul(amt);
        require(msg.value >= cost, "Insufficient funds!!!");
        ORDER[orderID].buyer = msg.sender;
        ORDER[orderID].contractAddr.safeTransferFrom(
            address(this),
            ORDER[orderID].buyer,
            ORDER[orderID].tokenID,
            amt,
            ""
        );
        ORDER[orderID].seller.transfer(cost);
        if (amt == ORDER[orderID].amount) ORDER[orderID].stage = Stage.SOLD;
    }
}
