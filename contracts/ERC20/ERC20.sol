//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract MyToken {
    uint256 public totalSupply;
    mapping (address => uint256) private balances;
    mapping (address=> mapping (address=> uint256)) private allowed;

    function balanceOf(address account) public view returns (uint256){
        return balances[account];
    }

    function transfer (address to, uint256 amount) public payable returns (bool){
        require(balances[msg.sender] > amount, "It is not enough tokens");
        balances[to] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance (address owner, address spender) public view returns (uint256){
        return allowed[owner][spender];
    }

    function approve (address spender, uint256 amount) public returns (bool){
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom (address from, address to, uint256 amount) public payable returns (bool){
        require(balanceOf(from) > amount, "It is not enough tokens");
        require(allowance(from, to) >= amount, "Operation is not allowed");
        allowed[from][to] -= amount;
        balances[to] += amount;
        balances[from] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSupply += amount;
    }


    event Transfer(address from, address to, uint256 amount);
    
    event Approval(address owner, address spender, uint256 amount);
}
