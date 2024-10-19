// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v3-core/contracts/libraries/TransferHelper.sol";

/*
 * Jeftar Mascarenhas
 * twitter: @jeftar
 * github: github.com/jeftarmascarenhas
 * linkedin: linkedin.com/in/jeftarmascarenhas/
 * site: jeftar.com.br
 * youtube: youtube.com/@nftchoose
 */
contract USDT is ERC20 {
    constructor() ERC20("Theter", "USDT") {}

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /**
     * Send 100 USDT to any wallet or smart contract
     */
    function mint(address account) external {
        _mint(account, 100 * 10 ** 6);
    }

    /**
     * Encode function transfer(address to, uint256 value) external returns (bool);
     */
    function encodeTransfer(
        address to,
        uint256 value
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, value);
    }
}
