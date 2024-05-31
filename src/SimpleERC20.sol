// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function totalSupply() external view  returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns(bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns(bool);
    function transferFrom(address sender, address to, uint256 _amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 _amount);
    event Approval(address indexed _owner, address indexed apender, uint256 _amount);
    
}

contract MyToken is IERC20 {
    string public constant name = "Cypher Token";
    string public constant symbol = "CYT";
    uint8 public constant decimal = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    constructor(uint256 totalsupply_) {
        _totalSupply = totalsupply_ * 10 ** uint256(decimal);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address _account
    ) public view override returns (uint256) {
        return _balances[_account];
    }

    function allowance(
        address _owner,
        address _spender
    ) external view override returns (uint256) {
        return _allowance[_owner][_spender];
    }

    function transfer(
        address _to,
        uint256 _amount
    ) external override returns (bool) {
        require( _to != address(0), "zero address recipient");
        require(_balances[msg.sender] >= _amount, "Transfer amount exceeds balance");
        _balances[msg.sender] -= _amount;
        _balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }


    function approve(
        address _spender,
        uint256 _amount
    ) external override returns (bool) {
        require(_spender != address(0), "Zero address spender not ");
        _allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;

    }

    function transferFrom(
        address sender,
        address to,
        uint256 _amount
    ) external override returns (bool) {
        require(sender != address(0), "Zero address sender");
        require(to != address(0), "Zero address recipient");
        require(_balances[sender] >= _amount, "transfer amount exceeds balance");
        require(_allowance[sender][msg.sender] >= _amount, "transfer amount exceeds allowance");

        _balances[sender] -= _amount;
        _balances[to] += _amount;
        _allowance[sender][msg.sender] -= _amount;

        emit Transfer(sender, to, _amount);

        return true;
    }
}