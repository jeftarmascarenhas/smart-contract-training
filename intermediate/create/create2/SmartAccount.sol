// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

/**
 * SmartAccount
 * @title Contract Smart Account
 * @author Jeftar Mascarenhas - NFT Choose
 * @notice Does not use this contract in production! It's only study.
 */
contract SmartAccount {
    address public signer;

    constructor(address _signer) {
        signer = _signer;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external {
        require(signer == msg.sender, "Only signer");
        (bool success, ) = payable(signer).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer Failure");
    }
}
