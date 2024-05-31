// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


interface IERC20 {

    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns(bool);
    function transferFrom(address sender, address to, uint256 _amount) external returns(bool);

    
}

contract PiggyBank{
    address public owner;
    IERC20 public token;
    mapping (address => uint256) private balances;


    uint256 public goalAmount;
    uint256 public deadline;


    address[] public approvers;
    uint256 public approvalRequired;
    mapping(address => bool) public approved;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    modifier onlyowner {
        require(msg.sender == owner, "Only owner can call function");
        _;
        
    }

    modifier goalreached{
            require(token.balanceOf(address(this)) >= goalAmount, "saving goal not reached");
            require(block.timestamp >= deadline, "deadline not reached");
            _;
    }

    constructor(
        address _tokenAddress,
        uint256 _goalAmount,
        uint256 _deadline,
        address[] memory _approvers,
        uint256 _approvalRequired
    ){
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        goalAmount = _goalAmount;
        deadline = _deadline;
        approvers = _approvers;
        approvalRequired = _approvalRequired;


    }

    function deposit(uint256 _amount) external{
        require(_amount > 0, "Deposit amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        balances[msg.sender]+= _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdrw(uint256 _amount) external goalreached {
        require(_amount <= token.balanceOf(address(this)), "Insuffuicient contract balance");
        require(token.transfer(msg.sender, _amount), "Token transfer failed");

        emit Withdrawal(owner, _amount);
    }

    function approveEmergencyWithdraw() external {
        require(isApprover(msg.sender), "Not an approver");
        approved[msg.sender] = true;
    }

    function emergencyWithdraw(uint256 _amount) external onlyowner{
        require(approvalsCount() >= approvalRequired, "Not enough approvals");
        require(_amount <= token.balanceOf(address(this)), "insufficient contract balance");

//Reset approvals
        for (uint256 i = 0; i < approvers.length; i++){
            approved[approvers[i]] = false;
        }

        require(token.transfer(owner, _amount), "Token transfer failed");
        emit Withdrawal(owner, _amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getTimeUntilDeadline() external view returns (uint256) {
        if (block.timestamp >= deadline){
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    //Helper function to check if an address is an approver 
    function isApprover(address _addr) internal view returns (bool){
        for (uint256 i = 0; i < approvers.length; i++){
            if(approvers[i] == _addr){
                return true;
            }
          
        }

        return false;
    }

    function approvalsCount() internal view returns (uint256 count) {
        for(uint256 i = 0; i < approvers.length; i++){
            if(approved[approvers[i]]){
                count++;
            }
        }
    }
}