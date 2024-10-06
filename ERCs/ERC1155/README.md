# ERC1155 Gaming Contract: Create and Manage Tokens

The primary goal of the ERC1155GamingExplained contract is to facilitate the creation and management of diverse token types within the gaming ecosystem. By leveraging the ERC1155 standard, this contract allows developers to issue both fungible and non-fungible tokens efficiently in a single deployment.

This implementation not only supports various in-game assets, such as currencies and unique items, but also incorporates features for tracking token balances and metadata. With built-in administrative controls, it ensures secure and flexible management of tokens, making it an ideal solution for game developers looking to enhance their projects with blockchain technology.

##

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/*
* @dev ERC1155GamingExplained is using ERC1155 for the creation of multi-tokens,
* ERC1155Supply which adds token tracking by returning its totalBalance and
* Ownable to ensure that only the owner of the contract can execute administrative functions of the contract.
*/
contract ERC1155GamingExplained is ERC1155, ERC1155Supply, Ownable {
    /*
    * @dev name is the name of the contract, commonly used by marketplaces.
    */
    string public constant name = "GamingExplained";
    /*
    * @dev tokens is the mapping necessary for managing different metadata URLs for each token
    * existing in the contract.
    */
    mapping(uint256 tokenId => TokenMetadata tokenInfo) public tokens;
    /*
    * @dev Customizable type used for creating
    */
    struct TokenMetadata {
        string tokenType;
        bool exists;
        string metadataURI;
    }

    /*
    * @dev The contractMetadata parameter
    */
    constructor(string memory contractMetadata) ERC1155(contractMetadata) Ownable(_msgSender()) {
        uint256 SWARD = 0;
        uint256 GOOLD = 1;
        uint256 DETONATOR_HAMMER = 2;
        // Initialize token IDs and values
        uint256[] memory TOKEN_IDS;
        uint256[] memory TOKEN_VALUES;

        TOKEN_IDS[SWARD] = SWARD;
        TOKEN_IDS[GOOLD] = GOOLD;
        TOKEN_IDS[DETONATOR_HAMMER] = DETONATOR_HAMMER;
        // Assign values to tokens
        TOKEN_VALUES[SWARD] = 3; // FUNGIBLE
        TOKEN_VALUES[GOOLD] = 1000; // FUNGIBLE
        TOKEN_VALUES[DETONATOR_HAMMER] = 1; // NON-FUNGIBLE
        // Define metadata for SWARD token
        tokens[SWARD] = TokenMetadata({
            tokenType: "SWARD",
            exists: true,
            // This sword is an NFT (non-fungible); there cannot be another identical sword.

            metadataURI: "https://example.com/api/swards/0.json"
        });
        // Define metadata for GOOLD token
        tokens[GOOLD] = TokenMetadata({
            tokenType: "GOOLD",
            exists: true,
            // Resources are coins and fungible (e.g., ERC20). Resource 0 is gold; silver could be 1...
            metadataURI: "https://example.com/api/recources/0.json"
        });
        // Mint initial batch of tokens to the contract owner
        _mintBatch(_msgSender(), TOKEN_IDS, TOKEN_VALUES, "");
    }

    /*
    * @dev Function to mint a single token. Only callable by the contract owner.
    */
    function mint(address account, uint256 tokenId, uint256 value) external onlyOwner {
        _mint(account, tokenId, value, "");
    }
   /*
    * @dev Function to mint a batch of tokens. Only callable by the contract owner.
    */
    function mintBatch(address account, uint256[] memory tokenIds, uint256[] memory values) external onlyOwner  {
        _mintBatch(account, tokenIds, values, "");
    }
    /*
    * @dev Function to retrieve the URI for a specific token's metadata.
    */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return tokens[tokenId].metadataURI;
    }

    /*
    * @dev contractURI is used by marketplaces like OpenSea to fetch contract-level metadata.
    */
    function contractURI() external view returns(string memory) {
        return super.uri(0);
    }

    /*
    * @dev The addToken method is not implemented to encourage you, the reader, to practice.
    * After reading and understanding, practice, rewrite, and improve this code; that's how you'll learn.
    * Remember, understanding is not learning! Dive into the code.
    */
    function addToken(uint256 tokenId) external onlyOwner {
        // Implement this method to practice adding new tokens.
    }

    /*
    * @dev Overriding is necessary in this case because ERC1155 and ERC1155Supply define this function.
    * It ensures proper updating of balances when transferring tokens.
    */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
```
