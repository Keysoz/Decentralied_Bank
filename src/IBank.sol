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
    event TransferContractOwnership(address indexed oldOwner, address indexed newOwner);

    /* Function Signatures */
    /**
     * @notice **Warning**: Don't Try To Deposit Zero Amount.
     * @dev For Security: The Zero Amount Deposit Check is Done.
     */
    function deposit() external payable;
    /**
     * @dev *I Used the CEI (Check-Effects-Interactions) in the Withdraw functions.**
     * - Check: check if user balance is not sufficient
     * - Effects: Make The Changes in the contract level first.
     * - Interactions: make `.call` to make the changes in the blockchain level
     * @param amount The Amount You Want to Withdraw
     */
    function withdraw(uint256 amount) external;
    /**
     * @notice **Note**: This Function Send Eth To Any Address Even Outside The Bank System (e.g. External Wallet).
     * @param amount The AMount You Want To Send.
     * @param receiver The Address Of The Receiver.
     */
    function transferTo(address receiver, uint256 amount) external;
    /**
     * @notice **Note**: This Function Send Eth Between Accounts Inside The Bank System.
     * @param amount The AMount You Want To Send.
     * @param receiver The Address Of The Receiver.
     */
    function transferInternal(address receiver, uint256 amount) external;
    /**
     * @notice **Warning**: Double Check `newOwner` Address.
     * @dev *This a Very Dangerous Function So Be Careful**
     * - It's a single step function.
     * - 2-step function is under development.
     * - double-check the address of the new owner for now.
     */
    function transferContractOwnership(address newOwner) external;
    /**
     * @dev *Note**: This Function can only be called in Emergency.
     */
    function pause() external;
    /**
     * @dev *Note**: This Function can only be called if The Danger Has gone.
     */
    function unpause() external;
    /**
     * @return The Total Balance of the Bank
     */
    function getTotalBalance() external view returns (uint256);
    /**
     * @param user The User Address That you want to know it's balance.
     * @return The Total Balance of the user in the Bank
     */
    function getBalance(address user) external view returns (uint256);
    /**
     * @return The current Owner of the Bank
     */
    function getCurrentOwner() external view returns (address);
}
