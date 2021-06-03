pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NMNFactory is ERC1155, Ownable {
    uint256 public lastID;

    constructor() public ERC1155("") {}

    function nftMint(
        address minter,
        string memory tokenURI,
        uint256 amt
    ) public {
        lastID++;
        _setURI(tokenURI);
        emit URI(tokenURI, lastID);
        _mint(minter, lastID, amt, "");
    }
}
