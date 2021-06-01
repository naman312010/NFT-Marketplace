// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NMNFactory is ERC1155,Ownable {
    constructor() public ERC1155("") {}

    
    
    function nftMint1(
        address minter,
        //string memory tokenURI,
        uint256 tokenId,
        uint256 amt
    ) public {
        //_setURI(tokenURI);
        //emit URI(tokenURI, tokenId);
        _mint(minter, tokenId, amt, "");
    }
}
