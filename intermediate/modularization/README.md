# Modularization smart contract with Library

How to modularization smart contract using library on solidity language

This smart contract has many features like:
- Create smart contacts
- Create Library

See how to make this smart contract [click here](https://www.youtube.com/@nftchoose)

<hr />

Como modularizar smart contract utilizando biblioteca na linguagem solidity

Este contrato inteligente tem muitos recursos como:
- Criar smart contracts
- Criar bibliotecas

Veja como fazer este smart contract [click here](https://www.youtube.com/@nftchoose)

## Default implementation store users 

```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract UserDefault {
     struct Info {
        string name;
        bool active;
    }

    mapping(address => Info) public users;

    function addUser(string calldata name_, address to_) external {
        users[to_] = Info(name_, true);
    }
}
```

## Modularization smart contract using library

```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library User {
    struct Info {
        string name;
        bool active;
    }

    struct Data {
        mapping(address => Info) users;
    }

    function addUser(Data storage data_ , string calldata name_, address to_) public  {
        data_.users[to_] = Info(name_, true);
    }

    function getUser(Data storage data_, address to_) public view returns(Info memory){
        return data_.users[to_];
    }
}

contract Consumer {
    User.Data data;

    function addUser(string calldata name_, address to_) external {
        User.addUser(data, name_, to_);
    }

    function getIsActive(address to_) external view returns(User.Info memory) {
        return User.getUser(data, to_);
    }
}

contract Farmer {
    User.Data data;

    function addUser(string calldata name_, address to_) external {
        User.addUser(data, name_, to_);
    }

    function getIsActive(address to_) external view returns(User.Info memory) {
        return User.getUser(data, to_);
    }
}
```