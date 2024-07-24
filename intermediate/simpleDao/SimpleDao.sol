// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// add member needs 1 ETH
// createProposal
// remover member
// vote
// execute

contract SimpleDao {
  uint256 public proposalIds;
  uint256 public totalMembers;
  uint256 public totalSupply;
  uint256 private constant NOT_ENTERED = 0;
  uint256 private constant ENTERED = 1;
  uint256 private status;

  mapping (uint256 => Proposal) public proposals;
  mapping (address => bool) public members;
  mapping (address => uint256) public balances;

  struct Proposal {
    address payable beneficiary;
    string description;
    uint256 amount;
    mapping(address => bool) votes;
    uint256 countVotes;
    bool executed;
  }

  event CreateProposal(uint256 indexed proposalId, address member);
  event ExecuteProposal(uint256 indexed proposalId, address member);
  event CreateVote(uint256 indexed proposalId, address member);
  event RemoveMember(address member);
  event AddNewMember(address member);
  
  error NotMember(address);
  error ProposalExecuted(uint256);
  error ProposalDoesntVotesEnough();
  error MemberExists();
  error WasVoted(address);
  error ProposalNotZero();
  error ValueNotEnough(uint256);
  error MemberRemoveWithdraw(address);

  constructor() {
    totalMembers++;
    members[msg.sender] = true;
    status = NOT_ENTERED;
  }

  modifier onlyMember {
    if (!members[msg.sender]) {
      revert NotMember(msg.sender);
    }
    _;
  }

  modifier checkProposal(uint256 proposalId) {
    if (proposalId == 0) {
        revert ProposalNotZero();
    }
    _;
  }

  modifier checkValue() {
    if (msg.value < 1 ether) {
        revert ValueNotEnough(msg.value);
    }
    if (msg.value > 1 ether) {
        payable(msg.sender).transfer(msg.value - 1 ether);
    }
    _;
  }

  modifier reentrancyGuard {
    if (status == ENTERED) {
      revert ReentrancyCall();
    } else {
      status = ENTERED;
    }
    _;
    status = NOT_ENTERED;
  }

  function createProposal(address payable beneficiary, uint256 amount, string memory description) external onlyMember returns(bool) {
    
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

  function vote(uint256 proposalId) external onlyMember checkProposal(proposalId) {
    if (proposals[proposalId].votes[msg.sender]) {
        revert WasVoted(msg.sender);
    }
    proposals[proposalId].countVotes++;
    emit CreateVote(proposalId, msg.sender);
  }

  function execute(uint256 proposalId) external onlyMember reentrancyGuard checkProposal(proposalId) {
    if(proposals[proposalId].executed) {
        revert ProposalExecuted(proposalId);
    }

    if (!(proposals[proposalId].countVotes > totalMembers / 2)) {
        revert ProposalDoesntVotesEnough();
    }
    
    if (proposals[proposalId].amount > balance) {
        revert ValueNotEnough();
    }

    (bool success, ) = proposals[proposalId].beneficiary.call{value: proposals[proposalId].amount}("");
    proposals[proposalId].executed = true;
    
    emit ExecuteProposal(proposalId, msg.sender);
  }
  
  function addMember() external payable checkValue {
    if(members[msg.sender]) {
        revert MemberExists();
    }
    members[msg.sender] = true;
    totalMembers++;
    balances[msg.sender] += msg.value;
    totalSupply += msg.value;
    emit AddNewMember(msg.sender);
  }
  
  function removeMember() external onlyMember reentrancyGuard {
    uint balance = balances[msg.sender];
    if (balance < 0) {
        revert ValueNotEnough(balance);
    }
   
    members[msg.sender] = false;
    balances[msg.sender] = 0;
    totalSupply -= balance;
    totalMembers--;

    (bool success,) = payable(msg.sender).call{value: balance}("");
    if(!success) {
        revert MemberRemoveWithdraw(msg.sender);
    }
    
    emit RemoveMember(msg.sender);
  }

}