// SPDX-License-Identifier: MIT
// Create by 0xYittle
// Air3Factory Version 2

pragma solidity ^0.8.19;

contract Air3Factory {

    event Pop(address indexed sender, uint amount, uint totalPop, uint chainId);

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

    function pop() external payable {

        require( popGas <= msg.value, "Insufficient funds");

        TotalPop += 1 ;
        
        emit Pop(msg.sender, msg.value, TotalPop, block.chainid);
        
        withdraw();
    }

    //------------------------- Withdraw Money

    function withdraw() public payable { 

        uint256 _pay10 = address(this).balance*10/100 ;
        uint256 _pay30 = address(this).balance*30/100 ;
        uint256 _pay40 = address(this).balance*40/100 ;

        require(address(this).balance > 0, "No ETH left");

        require(payable(0x80177a60961bdC8d67cd39D9a701c060237a66c6).send(_pay10)); // McTery
        require(payable(0xE8Fc136B5c63C7233319b27edeDa70E454E08f82).send(_pay10)); // Kayy
        require(payable(0xED9bc878a229Ad3D489f8a11F13AAf13B3bf4a26).send(_pay10)); // Yittle
        require(payable(0xcEB1f2eFE1cebEE66064AbB4fde8A20F0B32F931).send(_pay40)); // VAULT
        require(payable(Deployer).send(_pay30)); // Deployer Commission

    }
    
//------------------------- END Withdraw Money

}