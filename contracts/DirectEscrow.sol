pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract escrow is ERC1155Holder,ReentrancyGuard{
    
    using SafeMath for uint256;
    
    enum State {NO_SALE,AWAITING_OFFERS, AWAITING_TRANSFER, COMPLETE }
    State public currState;
    
    address buyer;
    address seller;
    address payable seller_payable;
    uint256 tokenId;
    uint256 amountRem;
    uint256 price;
    IERC1155 token;
    
    event TokenPurchased(address _seller,address _buyer, uint256 _tokenIdPurchased, uint256 _tokenPurchased);
    event SaleCancelled(address _seller);

    modifier onlySeller {
        require(msg.sender == seller);
        _;
    }

    function InitiateSale(address _tokenAdd,uint256 _tokenId, uint256 _amount, uint256 _price) public {         //IMPORTANT:The escrow needs approval from ERC1155 contract to work. Also, price in wei
        require(currState == State.NO_SALE,"Sale already going on");
        token = IERC1155(_tokenAdd);
        seller=msg.sender;
        seller_payable=payable(msg.sender);
        tokenId = _tokenId;
        amountRem = _amount;
        price = _price;
        token.safeTransferFrom(seller,address(this),tokenId,amountRem,"");
        currState=State.AWAITING_OFFERS;
    }
    
    function purchaseToken(uint256 tokenToBuy, uint256 amt) payable public {
        require(currState == State.AWAITING_OFFERS,"Nothing on sale");
        require(tokenToBuy == tokenId,"That token is not on sale");
        require(amountRem >= amt,"Not as many tokens on sale");
        require(msg.sender!=address(0),"Invalid buyer address");
        uint256 cost = price;
        cost = cost.mul(amt);
        require(address(this).balance >= cost,"Not enough ETH for amount to purchase");
        buyer=msg.sender;
        token.safeTransferFrom(address(this),buyer,tokenId,amt,"");
        amountRem = amountRem.sub(amt);
        seller_payable.transfer(cost);
        emit TokenPurchased(buyer,seller,tokenId,amt);
        buyer=address(0);
        
    }

    function cancelSale() onlySeller public {
        token.safeTransferFrom(address(this),seller,tokenId,amountRem,"");
        emit SaleCancelled(seller);
    }
    
}
   