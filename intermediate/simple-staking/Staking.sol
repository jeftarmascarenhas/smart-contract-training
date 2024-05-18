// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
    Jeftar Mascarenhas
    twitter: @jeftar
    github: github.com/jeftarmascarenhas
    linkedin: linkedin.com/in/jeftarmascarenhas/
    site: jeftar.com.br
    youtube: youtube.com/@nftchoose
*/

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface InterfaceERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 _amount) external;
}

contract Staking {
    // Neste Exemplo Ether será o token para fazer staking(Apostando)
    IERC20 public tokenToStake;
    // Neste Exemplo USDT será o token para reward(Recompensa)
    InterfaceERC20 public rewardToken;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastStakeTime;

    event Staked(address indexed _user, uint256 _amount);
    event Withdrawn(address indexed _user, uint256 _amount);
    event RewardPaid(address indexed _user, uint256 _reward);

    constructor(address _tokenToStake, address _rewardToken) {
        tokenToStake = IERC20(_tokenToStake);
        rewardToken = InterfaceERC20(_rewardToken);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Staking amount must be greater than 0");

        require(
            tokenToStake.balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );

        require(
            tokenToStake.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );

        if (stakedAmount[msg.sender] == 0) {
            lastStakeTime[msg.sender] = block.timestamp;
        }

        tokenToStake.transferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");

        require(
            stakedAmount[msg.sender] >= amount,
            "Insufficient staked amount"
        );

        uint256 reward = getReward(msg.sender);

        if (reward > 0) {
            rewardToken.mint(msg.sender, reward);

            emit RewardPaid(msg.sender, reward);
        }

        stakedAmount[msg.sender] -= amount;

        tokenToStake.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getReward(address _user) public view returns (uint256) {
        // tempo decorrido
        uint256 timeElapsed = block.timestamp - lastStakeTime[_user];
        uint256 stakedAmountUser = stakedAmount[_user];

        if (timeElapsed == 0 || stakedAmountUser == 0) {
            return 0;
        }

        return stakedAmountUser * timeElapsed;
    }

    function getStackBalance(address _user) external view returns (uint256) {
        return stakedAmount[_user];
    }
}
