pragma solidity >=0.4.22 <0.8.0;

import "./ERC20.sol";

contract DETF is ERC20 {

    constructor(address _accessContract) {
        _name = "dETF";
        _symbol = "dETF";
        _decimals = 18;
        accessContract = _accessContract;
    }
}
