// SPDX-License-Identifier: MIT
// Created by 0xYittle (Air3)

pragma solidity ^0.8.19;

contract Air3Factory {

    event Received(address, uint);

    uint256 public TotalPop ;
    uint256 public popGas = 0.0001 ether;
    address public Deployer ;
    
    constructor() {
        Deployer = msg.sender ;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
    _;
    }

    function pop () external payable {
        
        require( popGas <= msg.value, "Insufficient funds");

        TotalPop += 1 ;
    }

    //------------------------- Withdraw Money

    function withdrawMoney() external payable { 

        uint256 _pay10 = address(this).balance*10/100 ;
        uint256 _pay30 = address(this).balance*30/100 ;
        uint256 _pay40 = address(this).balance*40/100 ;

        require(address(this).balance > 0, "No ETH left");

        require(payable(0x17687aF7d159b3457F5542561E1c03aA7a5993A2).send(_pay10)); // McTery
        require(payable(0xE8Fc136B5c63C7233319b27edeDa70E454E08f82).send(_pay10)); // Kayy
        require(payable(0xED9bc878a229Ad3D489f8a11F13AAf13B3bf4a26).send(_pay10)); // Yittle
        require(payable(0xcEB1f2eFE1cebEE66064AbB4fde8A20F0B32F931).send(_pay30)); // VAULT
        require(payable(Deployer).send(_pay40)); // Deployer Commission

    }
//------------------------- END Withdraw Money

}
