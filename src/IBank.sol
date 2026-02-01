/**
 * @title Banking System
 * @author Ahmed Ramadan
 * @notice A Decentralized Banking System With The Core Functions of Any Traditional Bank=
 * @dev The Security of each function is tested in depth
 */

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.13;

interface IBank {
    /* Errors */
    error Bank__UserCantDepositZeroAmount();
    error Bank__UserCantWithdrawZeroAmount();
    error Bank__InsufficientBalance(uint256 available, uint256 required);
    error Bank__TransferFailed();
    error Bank__InvalidAddress(address receiver);
    error Bank__NotTheOwner();

    /* Events */
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event TransferTo(address indexed sender, address indexed receiver, uint256 amount);
    event TransferInternal(address indexed sender, address indexed receiver, uint256 amount);
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /* Function Signatures */
    function deposit() external payable;
    /**
     * @param amount the amount to be transferred
     * @notice This function to transfer external the bank
     */
    function withdraw(uint256 amount) external;
    /**
     * @param receiver the address you want to transfer to
     * @param amount the amount to be transferred
     * @notice This function to transfer external the bank
     */
    function transferTo(address receiver, uint256 amount) external;
    /**
     * @param receiver the address you want to transfer to
     * @param amount the amount to be transferred
     * @notice This function to transfer internal the bank
     */
    function transferInternal(address receiver, uint256 amount) external;
    /**
     * @param newOwner will be the new owner
     * @notice the newOwner will control the contract
     * @dev Warning: This is a single-step ownership transfer process
     */
    function transferOwnership(address newOwner) external;
    /**
     * @return The Total Balance of the BanK
     */
    function getTotalBalance() external view returns (uint256);
    /**
     * @param user the user you want to know it's balance
     * @return The Total Balance of the user in the Bank
     */
    function getBalance(address user) external view returns (uint256);
    /**
     * @return The current Owner of the Bank
     */
    function getCurrentOwner() external view returns (address);
}
