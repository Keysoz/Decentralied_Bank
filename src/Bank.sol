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

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IBank} from "./IBank.sol";

contract Bank is IBank, Pausable, ReentrancyGuard {
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

    modifier onlyOwner() {
        if (msg.sender != s_owner) revert Bank__UnauthorizedAccount(msg.sender);
        _;
    }

    /* Modifiers End */

    /* Functions Start */
    constructor() {
        s_owner = msg.sender;
    }

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
    function withdraw(uint256 amount) public override whenNotPaused nonReentrant {
        address withdrawer = msg.sender;
        uint256 withdrawerBalance = s_addressToBalance[withdrawer];

        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > withdrawerBalance || withdrawerBalance == 0) {
            revert Bank__InsufficientBalance(withdrawerBalance, amount);
        }

        s_addressToBalance[withdrawer] = withdrawerBalance - amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit Withdraw(msg.sender, amount);
    }

    /// @inheritdoc IBank
    function transferTo(address receiver, uint256 amount)
        public
        override
        whenNotPaused
        checkZeroAddress(receiver)
        nonReentrant
    {
        address sender = msg.sender;
        uint256 senderBalance = s_addressToBalance[sender];

        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > senderBalance || senderBalance == 0) {
            revert Bank__InsufficientBalance(senderBalance, amount);
        }

        s_addressToBalance[sender] = senderBalance - amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(receiver).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit TransferTo(sender, receiver, amount);
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
        if (amount > senderBalance) revert Bank__InsufficientBalance(senderBalance, amount);

        s_addressToBalance[sender] = senderBalance - amount;
        s_addressToBalance[receiver] += amount;

        emit TransferInternal(sender, receiver, amount);
    }

    /// @inheritdoc IBank
    function transferContractOwnership(address newOwner) public override onlyOwner {
        address oldOwner = s_owner;

        if (newOwner == address(0)) revert Bank__InvalidAddress(newOwner);

        s_owner = newOwner;

        emit TransferContractOwnership(oldOwner, newOwner);
    }

    /// @inheritdoc IBank
    function pause() external override onlyOwner whenNotPaused {
        _pause();
    }

    /// @inheritdoc IBank
    function unpause() external override onlyOwner whenPaused {
        _unpause();
    }
    /// @inheritdoc IBank

    function getTotalBalance() public view override onlyOwner returns (uint256) {
        return s_totalBankBalance;
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
