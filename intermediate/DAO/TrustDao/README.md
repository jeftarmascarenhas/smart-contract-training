# TrustDao

How to Create Your First DAO Contract: Exploring the TrustDAO Smart Contract

## _TrustDAO_ Smart Contract

- [TrustDao](./TrustDao.sol)

```javascript
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

/**
 * @title TrustDao
 * @notice Não use este contrato em produção.
 * @dev Este contrato implementa uma DAO simples com funcionalidades básicas.
 * Requisitos:
 * 1. Adicionar membro precisa enviar no mínimo 1 ETH
 * 2. Criar proposta
 * 3. Remover membro e reembolsar
 * 4. Apenas membros podem votar
 * 5. Qualquer membro pode executar a proposta
 */
contract TrustDao {
    uint256 public proposalIds;
    uint256 public totalMembers;
    uint256 public totalSupply;
    uint256 private constant NOT_ENTERED = 0;
    uint256 private constant ENTERED = 1;
    uint256 private status;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(address => uint256) public balances;

    struct Proposal {
        address payable beneficiary;
        string description;
        uint256 amount;
        mapping(address => bool) votes;
        uint256 countVotes;
        bool executed;
    }

    event CreateProposal(uint256 indexed proposalId, address indexed member);
    event ExecuteProposal(uint256 indexed proposalId, address indexed member);
    event CreateVote(uint256 indexed proposalId, address indexed member);
    event RemoveMember(address indexed member);
    event AddNewMember(address indexed member);

    error NotMember(address member);
    error ReentrancyCall();
    error ProposalExecuted(uint256 proposalId);
    error ProposalDoesntVotesEnough();
    error MemberExists();
    error WasVoted(address member);
    error ProposalNotZero();
    error ValueNotEnough(uint256 value);
    error MemberRemoveWithdraw(address member);
    error TransferFailure();

    constructor() {
        totalMembers++;
        members[msg.sender] = true;
        status = NOT_ENTERED;
    }

    /**
     * @notice Verifica se o chamador é um membro.
     */
    modifier onlyMember() {
        if (!members[msg.sender]) {
            revert NotMember(msg.sender);
        }
        _;
    }

    /**
     * @notice Verifica se a proposta é válida.
     * @param proposalId O ID da proposta a ser verificada.
     */
    modifier checkProposal(uint256 proposalId) {
        if (proposalId == 0) {
            revert ProposalNotZero();
        }
        _;
    }

    /**
     * @notice Verifica se o valor enviado é no mínimo 1 ETH.
     */
    modifier checkValue() {
        if (msg.value < 1 ether) {
            revert ValueNotEnough(msg.value);
        }
        if (msg.value > 1 ether) {
            payable(msg.sender).transfer(msg.value - 1 ether);
        }
        _;
    }

    /**
     * @notice Protege contra reentrância.
     */
    modifier reentrancyGuard() {
        if (status == ENTERED) {
            revert ReentrancyCall();
        }
        status = ENTERED;
        _;
        status = NOT_ENTERED;
    }

    /**
     * @notice Cria uma nova proposta.
     * @param beneficiary O endereço do beneficiário da proposta.
     * @param amount O valor solicitado na proposta.
     * @param description A descrição da proposta.
     * @return bool Retorna true se a proposta for criada com sucesso.
     */
    function createProposal(
        address payable beneficiary,
        uint256 amount,
        string memory description
    ) external onlyMember returns (bool) {
        proposalIds++;

        Proposal storage newProposal = proposals[proposalIds];
        newProposal.beneficiary = beneficiary;
        newProposal.description = description;
        newProposal.amount = amount;
        newProposal.votes[msg.sender] = true;
        newProposal.countVotes++;

        emit CreateProposal(proposalIds, msg.sender);

        return true;
    }

    /**
     * @notice Vota em uma proposta.
     * @param proposalId O ID da proposta a ser votada.
     */
    function vote(
        uint256 proposalId
    ) external onlyMember checkProposal(proposalId) {
        if (proposals[proposalId].votes[msg.sender]) {
            revert WasVoted(msg.sender);
        }
        proposals[proposalId].votes[msg.sender] = true;
        proposals[proposalId].countVotes++;
        emit CreateVote(proposalId, msg.sender);
    }

    /**
     * @notice Executa uma proposta.
     * @param proposalId O ID da proposta a ser executada.
     */
    function execute(
        uint256 proposalId
    ) external onlyMember reentrancyGuard checkProposal(proposalId) {
        if (proposals[proposalId].executed) {
            revert ProposalExecuted(proposalId);
        }

        if (!(proposals[proposalId].countVotes > totalMembers / 2)) {
            revert ProposalDoesntVotesEnough();
        }

        if (proposals[proposalId].amount > totalSupply) {
            revert ValueNotEnough(totalSupply);
        }

        (bool success, ) = proposals[proposalId].beneficiary.call{
            value: proposals[proposalId].amount
        }("");
        if (!success) {
            revert TransferFailure();
        }
        proposals[proposalId].executed = true;

        emit ExecuteProposal(proposalId, msg.sender);
    }

    /**
     * @notice Adiciona um novo membro.
     */
    function addMember() external payable checkValue {
        if (members[msg.sender]) {
            revert MemberExists();
        }
        members[msg.sender] = true;
        totalMembers++;
        balances[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit AddNewMember(msg.sender);
    }

    /**
     * @notice Remove um membro e reembolsa seu saldo.
     */
    function removeMember() external onlyMember reentrancyGuard {
        uint balance = balances[msg.sender];
        if (balance <= 0) {
            revert ValueNotEnough(balance);
        }

        members[msg.sender] = false;
        balances[msg.sender] = 0;
        totalSupply -= balance;
        totalMembers--;

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        if (!success) {
            revert MemberRemoveWithdraw(msg.sender);
        }

        emit RemoveMember(msg.sender);
    }
}

```
