/**
 * @title Banking System
 * @author Ahmed Ramadan
 * @notice A Decentralized Banking System With The Core Functions of Any Traditional Bank=
 * @dev The Security of each function is tested in depth
 */

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.13;

import {IBank} from "./IBank.sol";

contract Bank is IBank {
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
        if (msg.sender != s_owner) revert Bank__NotTheOwner();
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

    function deposit() public payable override {
        if (msg.value == 0) revert Bank__UserCantDepositZeroAmount();

        s_addressToBalance[msg.sender] += msg.value;
        s_totalBankBalance += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /// @inheritdoc IBank
    function withdraw(uint256 amount) public override {
        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        if (amount > s_addressToBalance[msg.sender]) {
            revert Bank__InsufficientBalance(s_addressToBalance[msg.sender], amount);
        }

        s_addressToBalance[msg.sender] -= amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit Withdraw(msg.sender, amount);
    }

    /// @inheritdoc IBank
    function transferTo(address receiver, uint256 amount) public override checkZeroAddress(receiver) {
        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        uint256 callerBalance = s_addressToBalance[msg.sender];
        if (amount > callerBalance) {
            revert Bank__InsufficientBalance(callerBalance, amount);
        }

        s_addressToBalance[msg.sender] -= amount;
        s_totalBankBalance -= amount;

        (bool success,) = payable(receiver).call{value: amount}("");
        if (!success) revert Bank__TransferFailed();

        emit TransferTo(msg.sender, receiver, amount);
    }

    /// @inheritdoc IBank
    function transferInternal(address receiver, uint256 amount) public override checkZeroAddress(receiver) {
        if (amount == 0) revert Bank__UserCantWithdrawZeroAmount();

        uint256 callerBalance = s_addressToBalance[msg.sender];
        if (amount > callerBalance) {
            revert Bank__InsufficientBalance(callerBalance, amount);
        }

        s_addressToBalance[msg.sender] -= amount;
        s_addressToBalance[receiver] += amount;

        emit TransferInternal(msg.sender, receiver, amount);
    }

    /// @inheritdoc IBank
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == address(0)) revert Bank__InvalidAddress(newOwner);
        address oldOWner = s_owner;
        s_owner = newOwner;
        emit TransferOwnership(oldOWner, newOwner);
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
