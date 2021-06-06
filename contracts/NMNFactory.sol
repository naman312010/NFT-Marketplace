pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NMNFactory is ERC1155, Ownable {
    uint256 public lastID;
    mapping(uint256 => string) public tokenURI;

    constructor() public ERC1155("") {}

    function nftMint(
        address minter,
        string memory _tokenURI,
        uint256 _amt
    ) public {
        lastID++;
        _setURI(_tokenURI);
        emit URI(_tokenURI, lastID);
        _mint(minter, lastID, _amt, "");
        tokenURI[lastID] = _tokenURI;
    }
}
