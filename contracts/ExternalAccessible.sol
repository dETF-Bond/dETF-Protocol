pragma solidity >=0.4.22 <0.8.0;

contract ExternalAccessible {

    address public accessContract;

    function checkAccess(address sender) public returns (bool) {
        bool result = Accessible(accessContract).checkAccess(sender);
        require(result == true);
        return true;
    }

    modifier hasAccess() {
        require(checkAccess(msg.sender));
        _;
    }
}
