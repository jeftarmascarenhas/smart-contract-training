// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Token de Recompensa - Reward Token
contract USDT is ERC20, Ownable {
    constructor() ERC20("USDT",  "USDT") {}

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
}