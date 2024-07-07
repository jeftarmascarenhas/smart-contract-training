// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * RealDigital
 * @title Contract to simulate Brazilin's CBDC
 * @author Jeftar Mascarenhas - NFT Choose
 * @notice Does not use this contract in production! It's only study.
 * buyer(comprador) = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
 */
contract RealDigital is ERC20, Ownable {
    constructor() ERC20("Real Digital", "RD") Ownable(_msgSender()) {}

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function mint(address account, uint256 value) external onlyOwner {
        _mint(account, value);
    }
}
