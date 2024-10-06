// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/*
* @dev ERC1155GamingExplained está usando ERC1155 para criação de multi-tokens,
* ERC1155Supply que adiciona rastreamento do token retornando seu totalBalance e
* Ownable para garantir que só o dono do contrato pode executar funções adminstrativas do contrato
*/
contract ERC1155GamingExplained is ERC1155, ERC1155Supply, Ownable {
    /*
    * @dev name é o nome do contrato, muito usado por marketplaces
    */
    string public constant name = "GamingExplained";
    /*
    * @dev tokens é o mapping é necessário para o gerenciamento diferentes metadaUrl de cada token
    * existente no contrato
    */
    mapping(uint256 tokenId => TokenMetadata tokenInfo) public tokens;
    /*
    * @dev Tipo customizável que serve para criar
    */
    struct TokenMetadata {
        string tokenType;
        bool exists;
        string metadataURI;
    }

    /*
    * @dev o paramêtro contractMetadata
    */
    constructor(string memory contractMetadata) ERC1155(contractMetadata) Ownable(_msgSender()) {
        uint256 SWARD = 0;
        uint256 GOOLD = 1;
        uint256 DETONATOR_HAMMER = 2;
        uint256[] memory TOKEN_IDS;
        uint256[] memory TOKEN_VALUES;

        TOKEN_IDS[SWARD] = SWARD;
        TOKEN_IDS[GOOLD] = GOOLD;
        TOKEN_IDS[DETONATOR_HAMMER] = DETONATOR_HAMMER;
        
        TOKEN_VALUES[SWARD] = 3; // FUNGIBLE
        TOKEN_VALUES[GOOLD] = 1000; // FUNGIBLE
        TOKEN_VALUES[DETONATOR_HAMMER] = 1; // NON-FUNGIBLE

        tokens[SWARD] = TokenMetadata({
            tokenType: "SWARD",
            exists: true,
            // Essa espada é um NFT(não fungível), não pode ter outra espada iguaal
            metadataURI: "https://example.com/api/swards/0.json"
        });
        
        tokens[GOOLD] = TokenMetadata({
            tokenType: "GOOLD",
            exists: true,
            // Recursos são moedas e fungíveis(ex: ERC20). Recurso 0 é ouro, prata poderia ser 1...;
            metadataURI: "https://example.com/api/recources/0.json" 
        });

        _mintBatch(_msgSender(), TOKEN_IDS, TOKEN_VALUES, "");
    }

    /*
    *
    */
    function mint(address account, uint256 tokenId, uint256 value) external onlyOwner {
        _mint(account, tokenId, value, "");
    }
    /*
    *
    */
    function mintBatch(address account, uint256[] memory tokenIds, uint256[] memory values) external onlyOwner  {
        _mintBatch(account, tokenIds, values, "");
    }
    /*
    *
    */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return tokens[tokenId].metadataURI;
    }
    
    /*
    * @ contractURI é utilizada por marketplace como OpenSea
    */
    function contractURI() external view returns(string memory) {
        return super.uri(0);
    }

    /*
    * @dev O metódo addToken não é implementado para força você que tá só lendo a práticar
    * Depois de ler em entender, pratique, rescreva, melhore este código, assim você vai aprender.
    * Lembre-se entender não é aprender! Mete bronca aí no código.
    */
    function addToken(uint256 tokenId) external onlyOwner {
        // implemente este método para práticar.
    }

    /*
    * Substituição(override) é necessária neste caso porque ERC1155 e ERC1155Supply definem esta função.
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