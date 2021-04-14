pragma solidity >=0.4.22 <0.8.0;

import "./Ownable.sol";

contract Accessible is Ownable {
    mapping(address => bool) public access;

    constructor() {
        access[msg.sender] = true;
    }

    modifier hasAccess() {
        require(checkAccess(msg.sender));
        _;
    }

    function checkAccess(address sender) public view returns (bool) {
        require(access[sender] == true);
        return true;
    }

    function removeAccess(address addr) public hasAccess returns (bool success) {
        access[addr] = false;
        return true;
    }

    function addAccess(address addr) public hasAccess returns (bool) {
        access[addr] = true;
        return true;
    }
}
