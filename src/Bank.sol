/**
 * @title: The Decentralized Bank
 * @author _Keysoz_
 * @notice **What To Expect**
 * - The System Does What a **traditional Bank** Does in a decentralized World.
 * - The Core Functions Are (Deposit, Withdraw, Transfer And Transfer Internally).
 * - The System is safe so no need to be worry.
 * @dev *The Security Concerns**
 * - The Modern Security Checks Are Done.
 * - Openzeppelin Modifiers (Ownable, Pausable) Are Used.
 * - The CEI (Check, Effects, Interactions) Are Used.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IBank} from "./IBank.sol";

contract Bank is IBank, Ownable, Pausable {
    /* State Variables Start */
    mapping(address => uint256) private s_addressToBalance;
    address private s_owner;
    uint256 private s_totalBankBalance;
    /* State Variables End */

    /* Modifiers Start */
    modifier checkZeroAddress(address receiver) {
        if (receiver == address(0)) revert Bank__InvalidAddress(receiver);
        _;
    }

    /* Modifiers End */

    /* Functions Start */
    constructor() Ownable(msg.sender) {}

    receive() external payable {
        deposit();
    }

    /// @inheritdoc IBank
    function deposit() public payable override {
        address depositor = msg.sender;
        uint256 depositAmount = msg.value;

        if (depositAmount == 0) revert Bank__UserCantDepositZeroAmount();

        s_addressToBalance[depositor] += depositAmount;
        s_totalBankBalance += depositAmount;

        emit Deposit(depositor, depositAmount);
    }

    /// @inheritdoc IBank
    function withdraw(uint256 amount) public override whenNotPaused {
        address withdrawer = msg.sender;
        uint256 withdrawerBalance = s_addressToBalance[msg.sender];

        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > withdrawerBalance || withdrawerBalance == 0) {
            revert Bank__InsufficientBalance(withdrawerBalance, amount);
        }

        s_addressToBalance[withdrawer] -= amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit Withdraw(msg.sender, amount);
    }

    /// @inheritdoc IBank
    function transferTo(address receiver, uint256 amount) public override whenNotPaused checkZeroAddress(receiver) {
        address caller = msg.sender;
        uint256 callerBalance = s_addressToBalance[msg.sender];

        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > callerBalance || callerBalance == 0) {
            revert Bank__InsufficientBalance(callerBalance, amount);
        }

        s_addressToBalance[caller] -= amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(receiver).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit TransferTo(caller, receiver, amount);
    }

    /// @inheritdoc IBank
    function transferInternal(address receiver, uint256 amount)
        public
        override
        whenNotPaused
        checkZeroAddress(receiver)
    {
        address sender = msg.sender;
        uint256 senderBalance = s_addressToBalance[msg.sender];

        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > senderBalance) {
            revert Bank__InsufficientBalance(senderBalance, amount);
        }

        s_addressToBalance[sender] -= amount;
        s_addressToBalance[receiver] += amount;

        emit TransferInternal(sender, receiver, amount);
    }

    /// @inheritdoc IBank
    function transferContractOwnership(address newOwner) public override onlyOwner {
        address oldOwner = s_owner;

        if (newOwner == address(0)) revert Bank__InvalidAddress(newOwner);

        s_owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /// @inheritdoc IBank
    function pause() external override onlyOwner {
        _pause();
    }

    /// @inheritdoc IBank
    function unpause() external override onlyOwner {
        _unpause();
    }
    /// @inheritdoc IBank

    function getTotalBalance() public view override onlyOwner returns (uint256) {
        return address(this).balance;
    }

    /// @inheritdoc IBank
    function getBalance(address user) public view override returns (uint256) {
        return s_addressToBalance[user];
    }

    /// @inheritdoc IBank
    function getCurrentOwner() public view override returns (address) {
        return s_owner;
    }
    /* Functions End */
}
