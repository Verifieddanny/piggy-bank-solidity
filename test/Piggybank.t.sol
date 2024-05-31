// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/SimplePliggybank.sol";
import {MyToken} from "../src/SimpleERC20.sol";


contract PiggyBankTest is Test{
        MyToken token;
        PiggyBank piggyBank;
        address owner;
        address user;
        address approver1;
        address approver2;
        address[] approvers;
        uint256 approvalsRequired = 2;
        uint256 goalAmount = 1000 * 10 ** 18; // 1000 tokens
        uint256 deadline = block.timestamp + 30 days;

        function setUp() public{
            owner = address(this);
            user = address(0x1);
            approver1 = address(0x2);
            approver2 = address(0x3);
            approvers.push(approver1);
            approvers.push(approver2);


             token = new MyToken(1000000 * 10 ** 18);

            token.transfer(user, 1000 * 10 ** 18);
            token.transfer(approver1, 1000 * 10 ** 18);
            token.transfer(approver2, 1000 * 10 ** 18);

            piggyBank = new PiggyBank(address(token), goalAmount, deadline, approvers, approvalsRequired );

            vm.prank(user);
            token.approve(address(piggyBank), 1000 * 10 ** 18);

            }

            function testDeposit() public {
                uint256 amountToDeposit = 500 * 10 ** 18;

                vm.prank(user);
                piggyBank.deposit(amountToDeposit);

                uint256 balance = piggyBank.getTotalBalance();

                
                assertEq(balance, amountToDeposit);


            }

            function testDepositInsufficientAllowance() public {
                vm.prank(user);
                token.approve(address(piggyBank), 100 * 10 ** 18);


                vm.expectRevert("transfer amount exceeds allowance");
                vm.prank(user);

                piggyBank.deposit(500 * 10 ** 18);
            }

            function testWIthdraw() public {
                uint256 amountToDeposit = 1000 * 10 ** 18;

                vm.prank(user);
                piggyBank.deposit(amountToDeposit);

                vm.warp(deadline + 1);
                vm.prank(user);
                piggyBank.withdrw(amountToDeposit);

                uint256 balance = token.balanceOf(user);

                assert(balance == amountToDeposit);
            }

            function testWithdrawGoalNotReached() public {
                uint256 amountToDeposit = 500 * 10 ** 18;

                vm.prank(user);
                piggyBank.deposit(amountToDeposit);

                vm.warp(deadline + 1);
                vm.expectRevert("saving goal not reached");
                vm.prank(owner);
                piggyBank.withdrw(amountToDeposit);
            }

            function testEmergencyWithdraw() public {
                uint256 amountToDeposit = 1000 * 10 ** 18;

                vm.prank(user);
                piggyBank.deposit(amountToDeposit);

                vm.prank(approver1);
                piggyBank.approveEmergencyWithdraw();

                vm.prank(approver2);
                piggyBank.approveEmergencyWithdraw();

                vm.prank(owner);
                piggyBank.emergencyWithdraw(amountToDeposit);

                uint256 balance = token.balanceOf(owner);
                
                assertEq(balance, token.totalSupply() - (amountToDeposit * 2));
            }

            function testEmergencyWithdrawNotEnoughApprovals() public { 
                uint256 amountToDeposit = 1000 * 10 ** 18;

                vm.prank(user);
                piggyBank.deposit(amountToDeposit);

                vm.prank(approver1);
                piggyBank.approveEmergencyWithdraw();

                vm.expectRevert("Not enough approvals");
                vm.prank(owner);
                piggyBank.emergencyWithdraw(amountToDeposit);




            }


        function testGetBalance() public {
            uint256 amountToDeposit = 500 * 10 ** 18;

            vm.prank(user);
            piggyBank.deposit(amountToDeposit);

            uint256 balance = piggyBank.getTotalBalance();

            assertEq(balance, amountToDeposit);

        }

        function testGetTotalBalance() public {
            uint256 amountToDeposit = 500 * 10 ** 18;

            vm.prank(user);
            piggyBank.deposit(amountToDeposit);

            uint256 totalBalance = piggyBank.getTotalBalance();

            assertEq(totalBalance, amountToDeposit);
        
        }

        function testGetTimeUntilDeadline() public view{
            uint256 timeUntilDeadline = piggyBank.getTimeUntilDeadline();
            assert(timeUntilDeadline > 0);
        }

        function testFuzzDeposit(uint256 amount) public {
            vm.assume(amount > 0 && amount <= 1000 * 10 ** 18);

            vm.prank(user);
            piggyBank.deposit(amount);


            uint256 balance = piggyBank.getTotalBalance();
            assert(balance == amount);
        }


}