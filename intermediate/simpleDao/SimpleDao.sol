// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// add member
// remover member
// vote
// execute

contract Dao {
  event createProposal(uint256 indexed proposalId, address member);
  
  error NoZeroAddress();
  error NotMember(address);
  
  uint256 public proposalId;

  mapping (proposalId => Proposal) public proposals;
  mapping (address => bool) public members;

  struct Proposal {
    string description;
    uint256 votes;
    bool executed;
  }

  constructor() {
    if (msg.sender == address(0)) {
      revert NoZeroAddress()
    }

    members[msg.sender] = true;
  }

  modifier onlyMember {
    if (!members[msg.sender]) {
      revert NotMember(msg.sender);
    }
    _;
  }

  function createProposal(Proposal newProposal) external onlyMember returns(bool) {
    proposals[proposalId] = newProposal;
    proposalId++;
  }

  function execute() external onlyMember {
    
  }

}