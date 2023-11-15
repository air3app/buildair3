// SPDX-License-Identifier: MIT
// Created by 0xYittle (Air3)

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "./ERC721ABurnable.sol";

contract NFT is ERC721A, ERC721ABurnable {
    
    event Received(address, uint);

    uint256 public mintPrice = 0.00018 ether ; //
    uint256 public burnPrice = 0.0001 ether ; //
    string private baseURI = "ipfs://bafkreid37cevfmf7psubjba7gh3jtqauebusjmzbzkh5h6kr3t6iq5b5ey/?id=";
    address public Deployer ;

    struct AddressDetail {
        uint256 WalletMinted ;
        uint256 WalletBurned ;
    }

    mapping(address => AddressDetail) public _addressDetail ;

    constructor() ERC721A("Air3 ERC721A", "A3721A") {
        Deployer = msg.sender ;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
    _;
    }

    function mintNFT(uint256 _mintAmount) external payable {
        require(mintPrice * _mintAmount <= msg.value, "Insufficient funds");

        _safeMint(msg.sender, _mintAmount);
        _addressDetail[msg.sender].WalletMinted += _mintAmount ;

    }

    function burnNFT (uint256 _tokenId) external payable {
        require(burnPrice <= msg.value, "Insufficient funds");

        burn(_tokenId);
         _addressDetail[msg.sender].WalletBurned += 1 ;
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
