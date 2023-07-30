// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    linkedin: linkedin.com/in/jeftarmascarenhas/
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/

contract BuildNFT is ERC721A, Ownable, Pausable {
    error ValueNotEnough(uint256 value);
    error MaxSupplyExcesseded(uint256 quantity);
    error MaxPerWallet(uint256 max);
    error FailedTransfer();

    event Withdrawn(address owner, uint256 value);

    // You can use this url https://ipfs.io/ipfs/QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
    string private _baseTokenURI;
    uint256 private _maxSupply = 10;
    uint256 private _pricePerToken = 1 ether;
    uint256 constant private _MAX_PER_WALLET = 2;

    mapping(address => uint8) public walletMinted;

    constructor(
        string memory uri_
    ) ERC721A("Build NFT", "BuildNFT") {
        _baseTokenURI = uri_;
        _mint(msg.sender, 2);
    }

    function mint(uint256 quantity_) external payable whenNotPaused {
        if(totalSupply() + quantity_ > _maxSupply) {
            revert MaxSupplyExcesseded(totalSupply() + quantity_);
        }

        if(_pricePerToken * quantity_ > msg.value) {
            revert ValueNotEnough(msg.value);
        }

        if (walletMinted[msg.sender] >= _MAX_PER_WALLET || quantity_ > _MAX_PER_WALLET) {
           revert MaxPerWallet(_MAX_PER_WALLET);
        }

        _mint(msg.sender, quantity_);
        walletMinted[msg.sender] += 1;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        if(!success) {
            revert FailedTransfer();
        }
        emit Withdrawn(msg.sender, balance);
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        _baseTokenURI = baseURI_;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, _toString(tokenId)))
                : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setPricePerToken(uint newPrice_) external onlyOwner {
        _pricePerToken = newPrice_;
    }

    function setMaxSupply(uint newSupply_) external onlyOwner {
        _maxSupply = newSupply_;
    }

    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
}
