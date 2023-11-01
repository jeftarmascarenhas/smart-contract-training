// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract UserDefault {
     struct Info {
        string name;
        bool active;
    }

    mapping(address => Info) users;

    function addUser(string calldata name_, address to_) external {
        // User.addUser(data, name_, to_);
        users[to_] = Info(name_, true);
    }
}

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