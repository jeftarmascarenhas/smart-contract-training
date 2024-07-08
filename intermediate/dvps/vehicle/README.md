# Vehicle DVP Delivery Versus Payment

This smart contract a simple form to create DvP to buyer and sell any vehicle, in this case DvP
We're simulate a DvP to Car.

**Note:** Important! This contracts is only to study and practice. Under no circumstances should this code be used in production.

Watch th video on [NFT Choose Channel](http://)

Smart Contracts

- [Vehicle](./Vehicle.sol)
- [Real Digital](./RealDigital.sol)
- [VehicleDvP](./VehicleDvP.sol)

## _Vehicle_ Smart Contract

```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Vehicles
 * @title Contract to register vehicles
 * @author Jeftar Mascarenhas - NFT Choose
 * @notice Does not use this contract in production! It's only study.
 * seller(vendedor): 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
 */
contract Vehicle is ERC721, Ownable {
    uint256 tokenIds;
    mapping(uint256 => VehicleRegister) public vehicles;

    error NotZeroAddress();

    struct VehicleRegister {
        string brand;
        string chassis;
        string model;
        uint256 year;
        uint256 createAt;
    }

    struct VehicleArg {
        string brand;
        string chassis;
        string model;
        uint256 year;
    }

    constructor() ERC721("Vehicles", "VHC") Ownable(_msgSender()) {}

    function register(
        address to,
        VehicleArg memory vehicle
    ) external onlyOwner returns (uint256 tokenId) {
        if (to == address(0)) revert NotZeroAddress();

        VehicleRegister storage newVehicle = vehicles[tokenIds];

        newVehicle.brand = vehicle.brand;
        newVehicle.chassis = vehicle.chassis;
        newVehicle.model = vehicle.model;
        newVehicle.year = vehicle.year;
        newVehicle.createAt = block.timestamp;

        _mint(to, tokenIds);

        tokenId = tokenIds;
        tokenIds++;
    }
}

```

## _Real Digital_ Smart Contract

```javascript
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

```

## _Vehicle DVP_ Smart Contract

```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./Vehicle.sol";
import "./RealDigital.sol";

/**
 * Aprenda a tokenizar um Carro com contrato inteligente e vende-lo usando Dvp e RealDigital
 * @author NFT Choose Youtube - Jeftar Mascarenhas
 */

/**
 * operationId: 0107072024
 * vehicleId: 0
 * Seller: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
 * Buyer: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
 * Price: 500000
 * OperationType: 0 or 1
 */
contract VehicleDvP {
    uint256 public dvpId;
    Vehicle public immutable vehicle;
    RealDigital public immutable cbdc;

    mapping(uint256 => Operation) public operations;

    enum OperationType {
        BUY,
        SELL
    }

    struct Operation {
        uint256 dvpId;
        uint256 vehicleId;
        address seller;
        address buyer;
        uint256 price;
        bool sellerConfirmed;
        bool buyerConfirmed;
        bool canceled;
        bool executed;
    }

    error OperationExecuted();
    error OperationCanceled();
    error OperationDoesNotMatch();
    error OperationNotOwnerOfCarro();
    error OperationInsufficientBalance();
    error OperationIncorrectSender(address sender);
    error OperationDoesNotExist(uint256 operationId);

    event OperationInitiating(
        address seller,
        address buyer,
        uint256 operationId
    );

    constructor(Vehicle _vehicle, RealDigital _cbdc) {
        vehicle = _vehicle;
        cbdc = _cbdc;
    }

    function dvpVehicle(
        uint256 operationId,
        uint256 vehicleId,
        address seller,
        address buyer,
        uint256 price,
        OperationType operationType
    ) external {
        dvpId++;
        Operation storage operation = operations[operationId];

        if (operation.dvpId == 0) {
            operation.dvpId = dvpId;
            operation.vehicleId = vehicleId;
            operation.price = price;
            operation.seller = seller;
            operation.buyer = buyer;

            emit OperationInitiating(seller, buyer, operationId);
        } else {
            checkOperation(
                operation,
                operationId,
                vehicleId,
                seller,
                buyer,
                price
            );
        }

        if (vehicle.ownerOf(vehicleId) != seller) {
            revert OperationNotOwnerOfCarro();
        }
        if (cbdc.balanceOf(buyer) < price) {
            revert OperationInsufficientBalance();
        }

        executeOperation(operationId, operationType);
    }

    function executeOperation(
        uint256 operationId,
        OperationType operationType
    ) internal {
        Operation storage operation = operations[operationId];

        if (operation.executed) {
            revert OperationExecuted();
        }

        if (operation.canceled) {
            revert OperationCanceled();
        }

        if (operationType == OperationType.BUY) {
            operation.buyerConfirmed = true;
        }

        if (operationType == OperationType.SELL) {
            operation.sellerConfirmed = true;
        }

        if (operation.sellerConfirmed && operation.buyerConfirmed) {
            vehicle.safeTransferFrom(
                operation.seller,
                operation.buyer,
                operation.vehicleId
            );
            cbdc.transferFrom(
                operation.buyer,
                operation.seller,
                operation.price
            );
            operation.executed = true;
        }
    }

    function dvpCancel(uint256 operationId) external {
        Operation storage operation = operations[operationId];
        if (operation.dvpId == 0) {
            revert OperationDoesNotExist(operationId);
        }

        if (operation.executed) {
            revert OperationExecuted();
        }

        if (operation.canceled) {
            revert OperationCanceled();
        }

        if (operation.seller == msg.sender || operation.buyer == msg.sender) {
            operation.canceled = true;
        } else {
            revert OperationIncorrectSender(msg.sender);
        }
    }

    function checkOperation(
        Operation memory operation,
        uint256 operationId,
        uint256 vehicleId,
        address seller,
        address buyer,
        uint256 price
    ) internal pure {
        bool isMatch = keccak256(
            abi.encode(
                operationId,
                operation.seller,
                operation.buyer,
                operation.vehicleId,
                operation.price
            )
        ) ==
            keccak256(abi.encode(operationId, seller, buyer, vehicleId, price));
        if (!isMatch) {
            revert OperationDoesNotMatch();
        }
    }
}

```
