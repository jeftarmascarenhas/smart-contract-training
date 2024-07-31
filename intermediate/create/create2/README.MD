# TrustDao

How to create the CREATE2 pattern

## _SmartAccount_ Smart Contract

- [Smart Account](./SmartAccount.sol.sol)

```javascript
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

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
      (bool success, ) = payable(signer).call{value: address(this).balance}("");
      require(success, "Transfer Failure");
    }
}

```

## _SmartAccount_ Smart Contract

- [Factory SmartAccount Create2](./Create2.sol)
  This contract is Factory contract that use CREATE2

```javascript
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "./SmartAccount.sol";

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
}
```
