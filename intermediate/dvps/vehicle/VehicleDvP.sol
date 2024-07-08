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
