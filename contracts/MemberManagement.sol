pragma solidity >=0.4.22 <0.9.0;

contract MemberManagement {
    
    struct Publisher {
        uint256 publisher_id;
        address public_address;
    }
    
    address owner;
    
    // publisher_id to publisher
    mapping (uint256 => Publisher) public publisher_directory;
    
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }
    
    event MemberRegistered(uint256 publisherId,address publisherAddress);
    event MemberAddressChanged(uint256 publisherId,address pumlisherAddress);
    
    constructor() {
        owner=msg.sender;
    }
    
    function registerMember(uint256 p_id,address p_address) onlyOwner public {
        require(publisher_directory[p_id].publisher_id == 0,"Publisher ID already registered");
        publisher_directory[p_id].publisher_id = p_id;
        publisher_directory[p_id].public_address = p_address;
        emit MemberRegistered(publisher_directory[p_id].publisher_id,publisher_directory[p_id].public_address);
    }
    
    function updateAddress(uint256 p_id,address p_address) public {
        require(publisher_directory[p_id].public_address == msg.sender,"Only member can change their address");
        publisher_directory[p_id].public_address=p_address;
        emit MemberAddressChanged(publisher_directory[p_id].publisher_id,publisher_directory[p_id].public_address);
    }
    
    function getAddress(uint256 p_id) virtual external returns (address) {
        return publisher_directory[p_id].public_address;
    }
}
