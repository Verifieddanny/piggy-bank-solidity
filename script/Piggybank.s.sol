// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Script, console} from "forge-std/Script.sol";
import {PiggyBank} from "../src/SimplePliggybank.sol";
import {MyToken} from "../src/SimpleERC20.sol";



contract deployPiggyBank is Script{
    MyToken public token;
    PiggyBank public piggyBank;


    address public owner;
    address public user;
    address public approver1;
    address public approver2;
    address[] public approvers;

    uint256 public goalAmount = 1000 * 10 **18;
    uint256 public deadline;


    function run() external{
        owner = msg.sender;
        user = vm.addr(1);
        approver1 = vm.addr(2);
        approver2 = vm.addr(3);
        approvers.push(approver1);
        approvers.push(approver2);

        vm.startBroadcast(owner);
        token = new MyToken(1000000 * 10**18);

        token.transfer(user, 500 * 10 ** 18);
        token.transfer(approver1, 500 * 10 ** 18 );
        token.transfer(approver2, 500 * 10 ** 18);


        deadline = block.timestamp;


        piggyBank = new PiggyBank(address(token), goalAmount, deadline, approvers, 2);

        vm.stopBroadcast();

        vm.startBroadcast(owner);
        token.approve(address(piggyBank), goalAmount);

        piggyBank.deposit(goalAmount);

        vm.startBroadcast();

        vm.warp(deadline + 1 days);

        vm.startBroadcast(owner);
        piggyBank.withdrw(goalAmount);

        vm.stopBroadcast();
    }

}