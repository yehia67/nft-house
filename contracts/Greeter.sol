//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        greeting = _greeting;
    }

    function greet() external view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory greeting_) external {
        greeting = greeting_;
    }
}
