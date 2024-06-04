// SPDX-License-Identifier: MIT
// Create By BlockBaron for Air3
// NFT + Ref Link

/*
 // การเรียงลำดับ ในการรับเงิน
 // 1. OWNER, 2. CORETEAM 3.Ref

 !!! = require to setup contract before final
*/

pragma solidity ^0.8.4;

import "./ERC721A.sol";

contract NFT is ERC721A {

    address public OWNER ;
    address public coreTeam = 0x3cD76a3E1Ae288c11459b986362ff2f63Ba0A379 ; // !!!
    // 0x3cD76a3E1Ae288c11459b986362ff2f63Ba0A379 = LEX Deployer for edit contract

    uint256 public mintPrice ;
    string private baseURI ;

    uint256 public mintStartDate ;
    uint256 public mintEndDate ;

    uint256 public maxSupply = 0 ;
    uint256 public maxPerWallet = 0 ;
    uint256 public tokenMinted = 0 ;
    
    bool public mintPause = false ;

//---- START PAYOUT

    address[] public _payoutAddress ;
    uint256[] public _payoutPercent ;

    // [0] Kayy, [1] Chrisx , [2] Terry , [3?] coreteam? 
    address[] public payoutCoreTeamAddress = [0xE8Fc136B5c63C7233319b27edeDa70E454E08f82, 0xED9bc878a229Ad3D489f8a11F13AAf13B3bf4a26, 0x80177a60961bdC8d67cd39D9a701c060237a66c6] ; // !!!
    uint256[] public payoutCoreTeamPercent = [0,0,0] ;

    address public payoutOwnerAddress ;

    uint256 public payoutOwnerPercent = 90 ;
    uint256 public payoutRefPercent = 10 ;

    address[] public payoutFinalAddress ;
    uint256[] public payoutFinalPercent ;
    
//---- END PAYOUT

    struct AddressData {
        uint256 WalletMinted ;
        uint256 WithdrawStatus ;
    }

    mapping(address => AddressData) public _addressData ;

    modifier onlyOwner() {
        require(OWNER == msg.sender , "You're not the owner");
        _;
    }

    modifier onlyParty() {
        require(OWNER == msg.sender || coreTeam == msg.sender , "You're not the Party");
        _;
    }


    modifier onlyCore() {
        require( coreTeam == msg.sender  , "You're not core team");
        _;
    }

    constructor(string memory _nftName, string memory _nftToken ,uint256 _mintPrice,
        string memory _newBaseURI, uint256 _mintStartDate, uint256 _mintEndDate,
        uint256 _maxSupply, uint256 _maxPerWallet)

    ERC721A(_nftName, _nftToken) {
        OWNER = msg.sender ;
        mintPrice = _mintPrice ;
        baseURI = _newBaseURI ;
        mintStartDate = _mintStartDate ; // Unix Timestamp
        mintEndDate = _mintEndDate ; // Unix Timestamp
        maxSupply = _maxSupply ;
        maxPerWallet = _maxPerWallet ;
        payoutOwnerAddress = msg.sender ;

        // เรียงข้อมูล Owner เป็นอันดับแรก
        payoutFinalAddress.push(msg.sender);
        payoutFinalPercent.push(payoutOwnerPercent);

        // เรียงยอดของ CORE TEAM เข้าไป

        for (uint i = 0; i < payoutCoreTeamAddress.length; i++) {
            payoutFinalAddress.push(payoutCoreTeamAddress[i]);
        }
        for (uint i = 0; i < payoutCoreTeamPercent.length; i++) {
            payoutFinalPercent.push(payoutCoreTeamPercent[i]);
        }


    }


//------------- START Mint Zone


    // not have referral ( ETH of Referral will go to OWNER )
    function mint(uint256 _mintAmount) external payable  {
        require(mintPause == false , "Minting is paused");
        require(mintStartDate <= block.timestamp , "Mint not start yet.");

        if(checkEndless() == false) {
            require(mintEndDate > block.timestamp , "Mint Ended.");
        }

        if(checkUnlimitedSupply() == false) {
            require( tokenMinted < maxSupply , "All token have been minted.");
            require( tokenMinted + _mintAmount <= maxSupply , "Can't mint more than max supply. Please try lower amount.");
        }

        if(checkMaxPerWallet() == true) {
            require( _addressData[msg.sender].WalletMinted < maxPerWallet, "Reached limit max per wallet.");
            require( _addressData[msg.sender].WalletMinted + _mintAmount <= maxPerWallet , "Please try lower amount.");
        }

        require(mintPrice * _mintAmount <= msg.value, "Insufficient funds.");

        uint256 _cost = mintPrice * _mintAmount ; 

        _safeMint(msg.sender, _mintAmount);
        _addressData[msg.sender].WalletMinted += _mintAmount ;
        _addressData[msg.sender].WithdrawStatus = 1 ;
        tokenMinted += _mintAmount;

        if(mintPrice > 0) {
            transferETH(msg.sender , payoutOwnerAddress, _cost) ;        
        }
        
    }

    // have referral
    function mint(uint256 _mintAmount, address _ref) external payable {
        require(mintPause == false , "Minting is paused");
        require(mintStartDate <= block.timestamp , "Mint not start yet.");
    
        if(checkEndless() == false) {
            require(mintEndDate > block.timestamp , "Mint Ended.");
        }
        
        if(checkUnlimitedSupply() == false) {
            require( tokenMinted < maxSupply , "All token have been minted.");
            require( tokenMinted + _mintAmount <= maxSupply , "Can't mint more than max supply. Please try lower amount.");
        }

        if(checkMaxPerWallet() == true) {
            require( _addressData[msg.sender].WalletMinted < maxPerWallet, "Reached limit max per wallet.");
            require( _addressData[msg.sender].WalletMinted + _mintAmount <= maxPerWallet  , "Please try lower amount.");
        }

        require(mintPrice * _mintAmount <= msg.value, "Insufficient funds.");

        uint256 _cost = mintPrice * _mintAmount ; 

        _safeMint(msg.sender, _mintAmount);
        _addressData[msg.sender].WalletMinted += _mintAmount ;
        _addressData[msg.sender].WithdrawStatus = 1 ;
        tokenMinted += _mintAmount;

        if(mintPrice > 0) {
            transferETH(msg.sender ,_ref, _cost) ;
        }
    }

    function devMint(uint256 _mintAmount, address _mintTo) public onlyParty {
        
        require( tokenMinted + _mintAmount <= maxSupply , "Can't mint more than max supply. Please try lower amount.");

        _safeMint(_mintTo, _mintAmount);

        tokenMinted += _mintAmount;

    }

//------------- END Mint Zone

//------------- START Setting Zone

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setNewStartDate (uint256 _mintStartDate) public onlyParty {
        mintStartDate = _mintStartDate ;
    }

    function setNewEndDate (uint256 _mintEndDate) public onlyParty {
        mintEndDate = _mintEndDate ;
    }

    function setBaseURI (string memory _newBaseURI) public onlyParty {
        baseURI = _newBaseURI ;
    }

    function setMintPrice (uint256 _mintPrice) public onlyParty {
        mintPrice = _mintPrice ;
    }

    function setPause(bool _pauseStatus) public onlyParty {
        mintPause = _pauseStatus ;
    }

    function setPayoutRefPercent (uint256 _percent) public onlyParty {
        
        // เช็คว่ายอดรวมเกิน 100% มั้ย
        uint256 totalPercent = _percent + payoutOwnerPercent + checkOnlyCorePayoutPercent();
        require(totalPercent <= 100, "you can't set total percent more than 100. (OWNER % + coreteam % + Ref %)");
        
        // เซท % ใน variable ของ refferral
        payoutRefPercent = _percent ;

    }

    function setPayoutOwnerPercent(uint256 _percent) public onlyParty {
        
        // เช็คว่ายอดรวมเกิน 100% มั้ย
        uint256 totalPercent = _percent + payoutRefPercent + checkOnlyCorePayoutPercent();
        require(totalPercent <= 100, "you can't set total percent more than 100. (OWNER % + coreteam % + Ref %)");

        // เซท % ใน variable ของ owner
        payoutOwnerPercent = _percent ;

        // ล้าง variable ของ final
        delete payoutFinalPercent ;
        payoutFinalPercent = new uint256[](0) ;

        // เรียงยอดของ OWNER เป็นอันดับแรก
        payoutFinalPercent.push(_percent);

        // เรียงยอดของ CORE TEAM เข้าไป
        for (uint i = 0; i < payoutCoreTeamPercent.length; i++) {
            payoutFinalPercent.push(payoutCoreTeamPercent[i]);
        }

    }

    function setPayoutOwnerAddress(address _ownerAddress) public onlyOwner {

        payoutOwnerAddress = _ownerAddress ;

         // ล้าง variable ของ final
        delete payoutFinalAddress ;
        payoutFinalAddress = new address[](0) ;

        // เรียงยอดของ OWNER เป็นอันดับแรก
        payoutFinalAddress.push(_ownerAddress);

        // เรียงยอดของ CORE TEAM เข้าไป
        for (uint i = 0; i < payoutCoreTeamAddress.length; i++) {
            payoutFinalAddress.push(payoutCoreTeamAddress[i]);
        }

    }

    function setMaxSupply(uint256 _maxSupply) public onlyParty {
        maxSupply = _maxSupply ;
    }

    function setMaxPerWallet(uint256 _maxperwallet) public onlyParty {
        maxPerWallet = _maxperwallet ; 
    }

//------------- END Setting Zone

//----------------- START Core Team Zone

    // สิทธิ์ในการแก้ไขข้อมูลต่างๆบน Contract นี้
    function setCoreTeam(address _address) public onlyCore {
        coreTeam = _address ;
    }

    function setPayoutCoreTeam(address[] memory _address, uint256[] memory _percent) public onlyCore {

        // เช็คว่า length ของทั้ง address และ percent เท่ากัน        
        require(_address.length == _percent.length) ;

        // จำนวน % ทั้งหมด เข้ามาในตัวแปรชั่วคราว
        uint256 totalPercent = payoutOwnerPercent + payoutRefPercent ;
        for (uint i = 0; i < _percent.length; i++) {
            totalPercent += _percent[i] ;
        }

        // เอาข้อมูลไปเช็คว่ากรอกมามากกว่า 100% มั้ย
        require(totalPercent <= 100, "you can't set total percent more than 100. (OWNER % + coreteam % + Ref %)");

        // เก็บค่าเข้าไปในตัวแปรถาวร
        payoutCoreTeamAddress = _address ;
        payoutCoreTeamPercent = _percent ;

        // ล้างค่าใน Fianl
        delete payoutFinalAddress ;
        delete payoutFinalPercent ;
        payoutFinalAddress = new address[](0) ;
        payoutFinalPercent = new uint256[](0) ;

        // เรียงข้อมูล Owner เป็นอันดับแรก
        payoutFinalAddress.push(payoutOwnerAddress);
        payoutFinalPercent.push(payoutOwnerPercent);

        // เรียงข้อมูลของ CoreTeam เข้าไปตามหลัง
        for (uint i = 0; i < _address.length; i++) {
            payoutFinalAddress.push(_address[i]);
        }
        for (uint i = 0; i < _percent.length; i++) {
            payoutFinalPercent.push(_percent[i]);
        }
        
    }

//----------------- END Core Team Zone

//--------- START Check Zone

    function checkTotalPayoutPercent() public view returns(uint256){
        uint256 totalPercent = payoutOwnerPercent + payoutRefPercent + checkOnlyCorePayoutPercent() ;

        return totalPercent ;
    }

    function checkOnlyCorePayoutPercent() public view returns(uint256){
        uint256 corePercent ;

        for (uint i = 0; i < payoutCoreTeamPercent.length; i++) {
            corePercent += payoutCoreTeamPercent[i] ;
        }

        return corePercent ;
    }

    function checkMaxPerWallet() public view returns(bool) {
        if(maxPerWallet == 0) {
            return false ;
        }
        return true ;
    }

    function checkEndless() public view returns(bool) {
        if(mintEndDate == 0) {
            return true ;
        }
        return false ; 

    }

    function checkUnlimitedSupply() public view returns(bool) {
        if(maxSupply == 0) {
            return true ;
        }
        return  false ;
    }

//--------- END Check Zone

//------------------------- START Withdraw Money

    function transferETH(address _minter, address _ref, uint256 _cost) public payable { 

        // ตรวจสอบเบื้องต้น
        require(_addressData[_minter].WithdrawStatus == 1 , "You're not minter");
        require(address(this).balance > 0, "No ETH left");
        require(address(this).balance >= _cost, "No ETH left");

        // สร้างตัวแปรชั่วคราว
        _payoutAddress = payoutFinalAddress ;
        _payoutPercent = payoutFinalPercent ;

        // เพิ่มข้อมูล Ref เข้าไป
        _payoutAddress.push(_ref);
        _payoutPercent.push(payoutRefPercent);
        

        // ทำจ่าย
        for (uint i = 0; i < _payoutAddress.length; i++) {
            uint256 _splitcost = _cost*_payoutPercent[i]/100 ;
            require(payable(_payoutAddress[i]).send(_splitcost));
        }

        require(payable(payoutOwnerAddress).send(address(this).balance));

        // ล้างข้อมูล
        delete _payoutAddress ;
        delete _payoutPercent ;
        _payoutAddress = new address[](0) ;
        _payoutPercent = new uint256[](0) ;

    }

//------------------------- END Withdraw Money

}