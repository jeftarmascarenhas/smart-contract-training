# How to create a Multi Sign Wallet Smart Contract

Multi Sign Wallets are smart contract that allow multiple signers to review and agree on action on the blockchain before action is executed.

For example, a multisign wallet could be used to control ETH, or smart contract, requiring signatures from
at least M of N total signers to execute the action.

See how to make this smart contract [click here](https://www.youtube.com/@nftchoose)

<hr />

How to make a pretty simple Multi Sign Wallet

Veja como fazer este smart contract [click here](https://www.youtube.com/@nftchoose)

## Multi Sign Wallet Smart Contract
```javascript
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
    mapping(uint256 => mapping(address => bool)) private approved;

    /**
    * For your test
    * owners_ = ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
    * required_ = 3
    */
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
        require(isOwner[msg.sender], "only owner");
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
        require(!transactions[txId_].executed, "txId already executed");
        _;
    }

    /**
    * For your test 
    * to = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
    * value = 1000000000000000000
    * data = "0x6e667463686f6f7365"
    */
    function submit(address to_, uint256 value_, bytes calldata data_) external onlyOwner {
        transactions.push(Transaction({
            to: to_,
            value: value_,
            data: data_,
            executed: false
        }));
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

    function _getApproveCount(uint256 txId_) public view returns(uint256 count) {
        for (uint256 i; i < owners.length; i++)  {
            if (approved[txId_][owners[i]]) {
                count+= 1;
            }
        }
        return count;
    }
}
```