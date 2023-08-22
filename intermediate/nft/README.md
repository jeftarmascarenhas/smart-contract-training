# How to create a complete and cheap NFT Smart Contract with ERC721A

This smart contract has many features like:
- Mint Batch
- Pausable
- Ownable
- Custom Error
- Withdraw
- Rewrite tokenURI
- Update NFT Price

See how to make this smart contract [click here](https://www.youtube.com/@nftchoose)

<hr />

Este contrato inteligente tem muitos recursos como:
- Mint Batch
- Pode ser pausado
- Funções exclusivas para o dono do contrato
- Erros customizados
- Retirada de ETH
- Estrita da função tokenURI
- Atualização de preço do NFT

Veja como fazer este smart contract [click here](https://www.youtube.com/@nftchoose)

## NFT Smart Contract with ERC721A

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFT is ERC721A, Ownable, Pausable {
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

    function mint(uint256 quantity) external payable whenNotPaused {
        if(totalSupply() + quantity > _maxSupply) {
            revert MaxSupplyExcesseded(totalSupply() + quantity);
        }

        if(_pricePerToken * quantity > msg.value) {
            revert ValueNotEnough(msg.value);
        }

        if (walletMinted[msg.sender] >= _MAX_PER_WALLET || quantity > _MAX_PER_WALLET) {
           revert MaxPerWallet(_MAX_PER_WALLET);
        }

        _mint(msg.sender, quantity);
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

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
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

    function setPricePerToken(uint newPrice) external onlyOwner {
        _pricePerToken = newPrice;
    }

    function setMaxSupply(uint supply) external onlyOwner {
        _maxSupply += supply;
    }

    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
}

```