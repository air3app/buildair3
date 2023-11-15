// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract counter {
    uint16 public a = 0;

    function increaseCounter() public{
     a += 1;
    }
}