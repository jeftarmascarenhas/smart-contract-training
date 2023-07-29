// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    linkedin: linkedin.com/in/jeftarmascarenhas/
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/

contract MultiSignWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed  txId);
    event Execute(uint256 txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    Transaction[] public transactions;
    uint256 public required;
    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public approved;

    constructor(address[] memory owners_, uint256 required_) {
        require(owners_.length > 0, "Owners should be greater than 0");
        require(required_ > 0 && required_ <= owners_.length, "Invalid require number of owners");
        for (uint i=0; i < owners_.length; i++) {
            address owner = owners_[i];
            require(owner != address(0), "Owner cannot be zero address");
            require(!isOwner[owner], "Owner already exists");
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = required_;
    }

    receive() payable external  {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(!isOwner[msg.sender], "only owner");
        _;
    }
    
    modifier txExists(uint256 txId_) {
        require(txId_ < transactions.length, "txId doesnt exists");
        _;
    }
    
    modifier notApproved(uint256 txId_) {
        require(!approved[txId_][msg.sender], "txId already approved");
        _;
    }
    
    modifier notExecuted(uint256 txId_) {
        require(transactions[txId_].executed, "txId already executed");
        _;
    }

    function submit(Transaction memory transaction_) external onlyOwner {
        transaction_.executed = false;
        transactions.push(transaction_);
        uint256 id = transactions.length - 1;
        emit Submit(id);
    }

    function approve(uint256 txId_) 
        external 
        onlyOwner
        txExists(txId_) 
        notApproved(txId_) 
        notExecuted(txId_) 
    {
        approved[txId_][msg.sender] = true;
        emit Approve(msg.sender, txId_);
    }
    
    function rekove(uint256 txId_) 
        external 
        onlyOwner
        txExists(txId_) 
        notApproved(txId_) 
        notExecuted(txId_) 
    {
        require(approved[txId_][msg.sender], "txId not approved");
        approved[txId_][msg.sender] = false;
        emit Revoke(msg.sender, txId_);
    }
    
    function execute(uint256 txId_) 
        external 
        onlyOwner
        txExists(txId_) 
        notExecuted(txId_) 
    {
        require(!transactions[txId_].executed, "txId already executed");
        require(_getApproveCount(txId_) >= required, "others owners should to approve");
        Transaction storage transaction = transactions[txId_];
        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}("");
        require(success, "Failed transfer value.");
        emit Execute(txId_);
    }

    function _getApproveCount(uint256 txId_) internal view returns(uint256 count) {
        for (uint256 i=0; 1 < owners.length; i++)  {
            if (approved[txId_][owners[i]]) {
                count++;
            }
        }
    }
}