// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * Specs
 * - Deve ser possível criar um documento onde uma ou mais partes possam assinar.
 * - Deve ser possível assinar um documento existente.
 * - Deve ser possível a qualquer pessoa verificar se o documento foi assinado.
 * ATENÇÃO: Este contrato é apenas para estudo, não foi auditado ou verificado sua segurança
 * e não deve ser utilizado em produção.
 * REMIX: https://remix.ethereum.org/#lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.24+commit.e11b9ed9.js
 **/
contract RegistryDocument {
    /**
     * Contém mappings para allowedSigners e signatures, uma lista de signers, contadores
     * para o total de assinaturas e assinaturas necessárias, e timestamps para a data de assinatura
     * e criação.
     **/
    struct Doc {
        mapping(address signer => bool isSigner) allowedSigners;
        mapping(address signer => bool isSigned) signatures;
        address[] signers;
        uint256 signaturesTotal;
        uint256 signaturesRequired;
        uint256 signatureDate;
        uint256 createAt;
    }
    /**
     * documents: mapeia o hash do documento para a estrutura Doc.
     **/
    mapping(string hash => Doc document) public documents;
    /**
     * Emitido quando um novo documento é criado.
     **/
    event DocCreated(address indexed signer, string indexed hash);
    /**
     * Emitido quando um documento é assinado.
     **/
    event Signed(address indexed signer, string indexed hash);
    /**
     * Emitido quando o documento atinge o número necessário de assinaturas.
     **/
    event SignedDoc(string indexed hash, uint256 indexed signatureDate);

    /**
     * Definidos para várias condições de erro, como documentos já assinados, número insuficiente de signatários,
     * e tentativas de assinar por partes não autorizadas.
     **/
    error DocSigned();
    error SignersRequiredNotEnough();
    error DocWasCreated();
    error SignerNotAllow();
    error SignatorySigned();
    error DocNotSigned();

    /**
     * Cria um novo documento e define os signatários permitidos.
     **/
    function createDoc(
        string memory hash,
        address[] memory signatureList,
        uint256 signaturesRequired
    ) external {
        Doc storage newDocument = documents[hash];

        if (signatureList.length != signaturesRequired) {
            revert SignersRequiredNotEnough();
        }

        if (newDocument.signatureDate > 0) {
            revert DocWasCreated();
        }

        for (uint256 i = 0; i < signatureList.length; i++) {
            newDocument.allowedSigners[signatureList[i]] = true;
            newDocument.signers.push(signatureList[i]);
        }

        newDocument.signaturesRequired = signaturesRequired;
        newDocument.createAt = block.timestamp;

        emit DocCreated(msg.sender, hash);
    }

    /**
     * Permite que signatários autorizados assinem o documento.
     **/
    function signDoc(string memory hash) external {
        Doc storage document = documents[hash];

        if (document.signatureDate > 0) {
            revert DocSigned();
        }

        if (!document.allowedSigners[msg.sender]) {
            revert SignerNotAllow();
        }

        if (document.signatures[msg.sender]) {
            revert SignatorySigned();
        }

        document.signatures[msg.sender] = true;
        document.signaturesTotal++;

        emit Signed(msg.sender, hash);

        if (document.signaturesTotal == document.signaturesRequired) {
            document.signatureDate = block.timestamp;
            emit SignedDoc(hash, block.timestamp);
        }
    }

    /**
     * Verifica se um documento foi assinado e retorna a lista de signatários e a data da assinatura.
     **/
    function verifyDoc(
        string memory hash
    ) external view returns (address[] memory, uint256) {
        if (documents[hash].signatureDate == 0) {
            revert DocNotSigned();
        }

        return (documents[hash].signers, documents[hash].signatureDate);
    }
}
