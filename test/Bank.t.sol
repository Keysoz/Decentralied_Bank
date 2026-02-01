// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// import {console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";
import {IBank} from "../src/IBank.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BankTest is Test {
    /* Events */
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event TransferTo(address indexed sender, address indexed receiver, uint256 amount);
    event TransferInternal(address indexed sender, address indexed receiver, uint256 amount);
    event TransferContractOwnership(address indexed oldOwner, address indexed newOwner);

    Bank bank;
    address public USER = makeAddr("USER");
    uint256 constant INITIAL_WALLET_BALANCE = 10 ether;
    uint256 constant DEPOSIT_AMOUNT = 5 ether;

    function setUp() public {
        bank = new Bank();
        vm.label(USER, "Keysoz");
        vm.deal(USER, INITIAL_WALLET_BALANCE);
    }

    function test_UserDepositAmountCorrect() public {
        // Arrange -> was handled by the setUp Function

        // Act
        vm.prank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();

        // Assert
        assertEq(USER.balance, INITIAL_WALLET_BALANCE - DEPOSIT_AMOUNT, "User Wallet Balance Should Decrease");
        assertEq(bank.getTotalBalance(), DEPOSIT_AMOUNT, "Bank ETH balance mismatch");
        assertEq(bank.getBalance(USER), DEPOSIT_AMOUNT, "Bank mapping (ledger) mismatch");
    }

    function test_RevertWhenDepositIsZero() public {
        // Arrange
        uint256 zeroAmount = 0;

        // Act & Assert
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__UserCantDepositZeroAmount.selector));
        bank.deposit{value: zeroAmount}();
    }

    function test_DepositIncreasesExistingBalance() public {
        // Arrange
        uint256 balanceBefore = bank.getBalance(USER);

        // Act
        vm.prank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();

        // Assert
        uint256 balanceAfter = bank.getBalance(USER);
        assertEq(balanceAfter, balanceBefore + DEPOSIT_AMOUNT, "Balance Should Increase By the Deposit Amount");
    }

    function test_FuzzDeposit(uint256 amount) public {
        // Arrange
        amount = bound(amount, 1 wei, 1000 ether);
        vm.deal(USER, amount);

        // Act
        vm.prank(USER);
        bank.deposit{value: amount}();

        // Assert
        assertEq(bank.getBalance(USER), amount, "The Bank Mapping Mismatch");
    }

    function test_MultipleDepositsToSameAccountsUpdatesTheCorrectAccountBalance() public {
        // Arrange
        uint256 walletBalance = 25 ether;
        uint256 depositAmount = 5 ether;
        vm.deal(USER, walletBalance);

        // Act
        vm.startPrank(USER);
        bank.deposit{value: depositAmount}();
        bank.deposit{value: depositAmount}();
        bank.deposit{value: depositAmount}();
        bank.deposit{value: depositAmount}();
        vm.stopPrank();

        // Assert
        assertEq(bank.getBalance(USER), depositAmount * 4, "Bank MApping Mismatch");
        assertEq(USER.balance, walletBalance - (depositAmount * 4), "Wallet Balance Mismatch");
    }

    function test_MultipleDepositsToMultipleAccountsUpdatesTheCorrectAccountBalance() public {
        // Arrange
        address user1 = makeAddr("user1");
        address user2 = makeAddr("user2");
        address user3 = makeAddr("user3");
        address user4 = makeAddr("user4");
        address user5 = makeAddr("user5");
        uint256 walletBalance = 10 ether;
        uint256 depositAmount = 2 ether;
        vm.deal(user1, walletBalance);
        vm.deal(user2, walletBalance);
        vm.deal(user3, walletBalance);
        vm.deal(user4, walletBalance);
        vm.deal(user5, walletBalance);

        // Act
        vm.prank(user1);
        bank.deposit{value: depositAmount}();
        vm.prank(user2);
        bank.deposit{value: depositAmount}();
        vm.prank(user3);
        bank.deposit{value: depositAmount}();
        vm.prank(user2);
        bank.deposit{value: depositAmount}();
        vm.prank(user3);
        bank.deposit{value: depositAmount}();
        vm.prank(user3);
        bank.deposit{value: depositAmount}();
        vm.prank(user4);
        bank.deposit{value: depositAmount}();
        vm.prank(user5);
        bank.deposit{value: depositAmount}();
        vm.prank(user5);
        bank.deposit{value: depositAmount}();
        vm.prank(user4);
        bank.deposit{value: depositAmount}();
        vm.prank(user1);
        bank.deposit{value: depositAmount}();

        // Assert
        assertEq(bank.getBalance(user1), depositAmount * 2, "User1 Mapping Mismatch");
        assertEq(bank.getBalance(user2), depositAmount * 2, "User2 Mapping Mismatch");
        assertEq(bank.getBalance(user3), depositAmount * 3, "User3 Mapping Mismatch");
        assertEq(bank.getBalance(user4), depositAmount * 2, "User4 Mapping Mismatch");
        assertEq(bank.getBalance(user5), depositAmount * 2, "User5 Mapping Mismatch");
        assertEq(user1.balance, walletBalance - (depositAmount * 2), "User1 Wallet Balance Mismatch");
        assertEq(user2.balance, walletBalance - (depositAmount * 2), "User2 Wallet Balance Mismatch");
        assertEq(user3.balance, walletBalance - (depositAmount * 3), "User3 Wallet Balance Mismatch");
        assertEq(user4.balance, walletBalance - (depositAmount * 2), "User4 Wallet Balance Mismatch");
        assertEq(user5.balance, walletBalance - (depositAmount * 2), "User5 Wallet Balance Mismatch");
    }

    function test_DepositEmitsCorrectEvent() public {
        // Arrange
        vm.prank(USER);

        // Act
        vm.expectEmit(true, false, false, true);
        emit Deposit(USER, DEPOSIT_AMOUNT);
        // Assert
        bank.deposit{value: DEPOSIT_AMOUNT}();
    }

    function test_DepositAfterWithdrawBehaveCorrectly() public {
        // Arrange
        vm.startPrank(USER);

        // Act
        bank.deposit{value: 6 ether}();
        bank.withdraw(3 ether);
        bank.deposit{value: 4 ether}();
        bank.withdraw(2 ether);
        vm.stopPrank();

        //Assert
        assertEq(bank.getBalance(USER), 5 ether, "Mapping User Balance Mismatch");
        assertEq(USER.balance, 5 ether, "User Wallet Balance Mismatch");
        assertEq(bank.getTotalBalance(), bank.getBalance(USER), "Bank Total Ether Mismatch");
    }

    // -------------------------------------------------------------------------
    // function testDepositFromAnotherContractAddress() public {}
    // function testReentrancyAttack() public {}
    // function testMaliciousFallbackDoseNotBreakDeposit() public {}
    // function testStateInvariant() public {}
    // function testGasUsageIsWithinExpectedRange() public {}
    // function testReceiveAndFallback() public {}// if someone send eth without calling deposit function
    // ---------------------------------------------------------------------------

    function test_withdrawFullAmount(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        amount = 5 ether;

        // Act
        bank.deposit{value: DEPOSIT_AMOUNT}();
        bank.withdraw(amount);
        vm.stopPrank();

        // Assert
        assertEq(bank.getBalance(USER), 0, "User Account is zero");
        assertEq(USER.balance, INITIAL_WALLET_BALANCE, "The Wallet Balance is 10 ether");
    }

    function test_withdrawPartialAmount(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();
        amount = 12500 wei;

        // Act
        bank.withdraw(amount);
        vm.stopPrank();

        // Assert
        assertEq(bank.getBalance(USER), (DEPOSIT_AMOUNT - amount), "User Account is zero");
        assertEq(USER.balance, INITIAL_WALLET_BALANCE - bank.getBalance(USER), "The Wallet Balance is 10 ether");
    }

    function test_WithdrawZeroAmountReverts(uint256 amount) public {
        vm.startPrank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();
        amount = 0 ether;

        // Act & Assert
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__UserCantWithdrawZeroAmount.selector));
        bank.withdraw(amount);
        vm.stopPrank();
    }

    function test_WithdrawAmountLessThanBalance(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();
        amount = 7 ether;

        // Act & Assert
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__InsufficientBalance.selector, bank.getBalance(USER), amount));
        bank.withdraw(amount);
        vm.stopPrank();
    }

    function test_withdrawIncreaseUserBalanceAndDecreaseInternalMapping(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        amount = 3 ether;

        // Act
        bank.deposit{value: DEPOSIT_AMOUNT}();
        uint256 balanceBefore = USER.balance;
        uint256 mapBefore = bank.getBalance(USER);
        bank.withdraw(amount);
        vm.stopPrank();
        uint256 balanceAfter = USER.balance;
        uint256 mapAfter = bank.getBalance(USER);

        // Assert
        assertGt(balanceAfter, balanceBefore);
        assertGt(mapBefore, mapAfter);
    }

    function test_multipleWithdrawsBalanceToZero(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        bank.deposit{value: DEPOSIT_AMOUNT}();
        uint256 amount1 = bound(amount, 1 wei, DEPOSIT_AMOUNT - 1 wei);
        uint256 amount2 = DEPOSIT_AMOUNT - amount1;

        // Act
        bank.withdraw(amount1);
        bank.withdraw(amount2);
        vm.stopPrank();

        //Assert
        assertEq(bank.getBalance(USER), 0, "Bank mapping should be empty");
        assertEq(USER.balance, INITIAL_WALLET_BALANCE, "Wallet balance should be restored");
    }

    function test_withdrawFromEmptyAccountRevert(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        amount = 2 ether;

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(IBank.Bank__InsufficientBalance.selector, bank.getBalance(USER), 2 ether)
        );
        bank.withdraw(amount);
        vm.stopPrank();
    }

    function test_fuzzingOnlyOwnerCanWithdraw(address attacker, address victim, uint256 amount) public {
        // Arrange
        attacker = makeAddr("attacker");
        victim = makeAddr("victim");
        amount = 5 ether;
        uint256 depositAmount = 5 ether;
        uint256 initialWalletBalance = 5 ether;
        vm.deal(victim, initialWalletBalance);
        vm.deal(attacker, initialWalletBalance);

        // Act & Assert
        vm.prank(victim);
        bank.deposit{value: depositAmount}();
        vm.startPrank(attacker);
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__InsufficientBalance.selector, 0, amount));
        bank.withdraw(amount);
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__InsufficientBalance.selector, 0, amount));
        bank.transferTo(victim, amount);
        vm.stopPrank();
    }

    function test_withdrawEmitsCorrectEvent(uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        amount = 5 ether;

        // Act & Assert
        bank.deposit{value: DEPOSIT_AMOUNT}();
        vm.expectEmit(true, false, false, true);
        emit Withdraw(USER, amount);
        bank.withdraw(amount);
        vm.stopPrank();
    }

    function test_transferToZeroAddressRevert(address receiver, uint256 amount) public {
        // Arrange
        vm.startPrank(USER);
        receiver = address(0);
        amount = 2 ether;

        // Act && Assert
        bank.deposit{value: DEPOSIT_AMOUNT}();
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__InvalidAddress.selector, receiver));
        bank.transferTo(receiver, amount);
        vm.stopPrank();
    }

    function test_transferToEmitsCorrectEvent(address receiver, uint256 amount) public {
        // Arrange
        receiver = makeAddr("receiver");
        vm.startPrank(USER);
        amount = 5 ether;

        // Act & Assert
        bank.deposit{value: DEPOSIT_AMOUNT}();
        vm.expectEmit(true, true, false, true);
        emit TransferTo(USER, receiver, amount);
        bank.transferTo(receiver, amount);
        vm.stopPrank();
    }

    function test_transferInternalDealsWithBalancesCorrectly(address receiver, uint256 amount) public {
        // Arrange
        receiver = makeAddr("RECEIVER");
        uint256 depositAmount = DEPOSIT_AMOUNT;
        amount = 3 ether;
        vm.startPrank(USER);

        // Act
        bank.deposit{value: depositAmount}();
        bank.transferInternal(receiver, amount);
        vm.stopPrank();

        // Assert
        vm.assertEq(bank.getBalance(receiver), amount, "The Receiver Balance Didn't increase");
        vm.assertEq(bank.getBalance(USER), depositAmount - amount, "The Sender Balance Still The Same");
    }

    function test_ownerCanTransferOwnershipToNewOwner(address newOwner) public {
        //Arrange
        address oldOwner = address(this);
        newOwner = makeAddr("newOwner");

        // Act & Assert
        vm.prank(oldOwner);
        bank.transferContractOwnership(newOwner);
        assertEq(bank.getCurrentOwner(), newOwner, "Transfer Failed!!!");
    }

    function test_TransferOwnershipToZeroAddressReverts(address newOwner) public {
        // Arrange
        address oldOwner = address(this);
        newOwner = address(0);

        // Act & Assert
        vm.startPrank(oldOwner);
        vm.expectRevert(abi.encodeWithSelector(IBank.Bank__InvalidAddress.selector, newOwner));
        bank.transferContractOwnership(newOwner);
        vm.stopPrank();
    }

    function test_notOwnerTransferOwnershipReverts(address newOwner) public {
        // Arrange
        address nonOwner = makeAddr("oldOwner");
        newOwner = makeAddr("newOwner");

        // Act & Assert
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        vm.startPrank(nonOwner);
        bank.transferContractOwnership(newOwner);
        vm.stopPrank();
    }

    function test_getBankTotalBalance() public {
        // Arrange
        address userOne = makeAddr("userOne");
        address userTwo = makeAddr("userTwo");
        address userThree = makeAddr("userThree");
        vm.deal(userOne, 8 ether);
        vm.deal(userTwo, 16 ether);
        vm.deal(userThree, 43 ether);

        // Act
        vm.prank(userOne);
        bank.deposit{value: 4 ether}();
        vm.prank(userTwo);
        bank.deposit{value: 10 ether}();
        vm.prank(userThree);
        bank.deposit{value: 25 ether}();

        // Assert
        uint256 bankTotalBalance = bank.getTotalBalance();
        uint256 expectedBalance = bank.getBalance(userOne) + bank.getBalance(userTwo) + bank.getBalance(userThree);
        assertEq(bankTotalBalance, expectedBalance);
    }

    function test_transferInternalEmitsCorrectEvent(address receiver, uint256 amount) public {
        // Arrange
        receiver = makeAddr("receiver");
        vm.startPrank(USER);
        amount = 5 ether;

        // Act & Assert
        bank.deposit{value: DEPOSIT_AMOUNT}();
        vm.expectEmit(true, true, false, true);
        emit TransferInternal(USER, receiver, amount);
        bank.transferInternal(receiver, amount);
        vm.stopPrank();
    }
}
