## Testing Cases For Each Features

### Deposit Eth

- **Basic Functionality**
  - [x] Deposit amount > 0 succeeds: Basic "Happy Path" test.
  - [x] Deposit updates user balance: Verifies the internal s_addressToBalance mapping increases.
  - [x] Deposit updates contract balance: Verifies the actual ETH held by the contract matches.
  - [x] Multiple deposits from one user: Ensure balances accumulate (1 ETH + 1 ETH = 2 ETH).
  - [x] Multiple users isolated: User A’s deposit does not affect User B’s balance.
  - [x] Deposit emits correct event: Validates that off-chain tools can see the Deposit log.
- **Security & Reversions**
  - [x] Deposit amount = 0 reverts: Prevents gas waste and "empty" logs.
  - [x] Invalid ETH value: (Usually handled by EVM, but good to test "insufficient user funds").
  - [ ] Reentrancy attack fails: While deposit is usually safe, testing ensures no state is corrupted during calls.
  - [x] Overflow check: In Solidity 0.8+, uint256 overflows are handled automatically, but a fuzz test confirms it.
- **Edge Cases**
  - [ ] Deposit from a Contract: Ensures the bank accepts ETH from smart contract wallets (multisig).
  - [x] Deposit after Withdraw: Verifies the state can go up, down, and back up without corruption.
  - [x] Dust Deposit: Testing with 1 wei to ensure no precision loss.
  - [ ] Malicious fallback: Ensures the bank still functions if a user tries to send ETH via a complex fallback.
- **Invariants & Gas**
  - [ ] State Invariant: The sum of all mapping balances MUST equal address(this).balance.
  - [ ] Gas benchmarking: Deposit costs should be consistent regardless of how many users are in the system.
---
### Withdraw Eth
- **Basic Functionality**
  - [x] Partial withdraw succeeds (Withdraw < balance)
  - [x] Full withdraw succeeds (Withdraw == balance)
  - [x] Withdraw amount = 0 succeeds (Or reverts, depending on your business logic)
  - [x] Withdraw updates user balance (Decreases internal mapping)
  - [x] Withdraw transfers actual ETH (Increases user's wallet balance)
  - [x] Multiple withdrawals correctly deplete the balance to zero

- **Security & Reversions (The "Sad Path")**
  - [x] Withdraw amount > balance reverts (Should trigger Bank__InsufficientBalance)
  - [x] Withdraw from empty account reverts
  - [x] Zero address withdrawal (If applicable to your logic)
  - [ ] Reentrancy attack fails (The most critical test for any withdraw function)
  - [x] Unauthorized withdrawal (Ensuring msg.sender can only withdraw their own funds)

- **Edge Cases & Invariants**
  - [ ] Withdrawal to a contract that refuses ETH (e.g., a contract with no receive function)
  - [ ] Withdrawal to a contract with a malicious receive (Checks-Effects-Interactions test)
  - [ ] Multiple users withdrawing simultaneously do not interfere with each other
  - [x] Withdraw emits correct event (e.g., event Withdraw(address indexed user, uint256 amount))
  - [ ] State Invariant: Total contract ETH must always equal the sum of all mapping balances.
  - [x] Dust withdrawal: Ensure the function works for 1 wei.
 
- **Advanced & Gas**
  - [ ] Withdraw after contract destruction/upgrade (If applicable)
  - [ ] Gas usage consistency: Ensure withdrawing doesn't become exponentially expensive as the mapping grows.