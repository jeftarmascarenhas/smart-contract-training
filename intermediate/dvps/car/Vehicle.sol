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
