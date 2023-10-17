// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// add member needs 1 ETH
// createProposal
// remover member
// vote
// execute

contract SimpleDao {
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
  
  uint256 public proposalIds;
  uint256 public totalMembers;
  uint256 public totalSupply;

  mapping (uint256 => Proposal) public proposals;
  mapping (address => bool) public members;
  mapping (address => uint256) public balances;

  struct Proposal {
    string description;
    mapping(address => bool) votes;
    uint256 countVotes;
    bool executed;
  }

  constructor() {
    totalMembers++;
    members[msg.sender] = true;
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

  function createProposal(string memory description) external onlyMember returns(bool) {
    
    proposalIds++;

    Proposal storage newProposal = proposals[proposalIds];
    
    newProposal.description = description;
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

  function execute(uint256 proposalId) external onlyMember checkProposal(proposalId) {
    if(proposals[proposalId].executed) {
        revert ProposalExecuted(proposalId);
    }

    if (!(proposals[proposalId].countVotes > totalMembers / 2)) {
        revert ProposalDoesntVotesEnough();
    }

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
  
  function removeMember() external onlyMember {
    uint balance = balances[msg.sender];
    if (balance < 0) {
        revert ValueNotEnough(balance);
    }
    members[msg.sender] = false;
    balances[msg.sender] = 0;
    (bool success,) = payable(msg.sender).call{value: balance}("");
    if(!success) {
        revert MemberRemoveWithdraw(msg.sender);
    }
    totalSupply -= balance;
    totalMembers--;
    emit RemoveMember(msg.sender);
  }

}