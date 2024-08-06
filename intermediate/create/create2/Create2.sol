// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "./SmartAccount.sol";

/**
 * FactorySmartAccountCreate2
 * @title Contract to use CREATE2
 * @author Jeftar Mascarenhas - NFT Choose
 * @notice Does not use this contract in production! It's only study.
 */
contract FactorySmartAccountCreate2 {
    event Deployed(address addr);

    function deploy(uint256 salt, address signer) external  {
        SmartAccount smartAccount = new SmartAccount{
            salt: bytes32(salt)
        }(signer);
        emit Deployed(address(smartAccount));
    }

    function getAddress(uint256 salt, address signer) public view returns(address) {
        address predictedAddress = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(SmartAccount).creationCode,
                abi.encode(signer)
            ))
        )))));
        return predictedAddress;
    }

    function sendEther(address to) external payable {
        (bool success, ) = payable(to).call{value: msg.value}("");
        require(success, "Send ETH Failure");
    }
}
