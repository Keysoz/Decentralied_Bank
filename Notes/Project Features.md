# Project Name: Bank Smart Contract

## Core Features

- **Deposit Eth**
  - User Can Deposit Any amount of Eth
  - deposit amount > 0
  - deposit Makes account balance increases
- Variables -> amount
- **Withdraw Eth**
  - user can withdraw if balance > 0
  - withdraw amount > 0
  - withdraw decrease acc balance
- **Check Balance**
  - each user check his balance
- **pause/unpause contract**
  - owner can pause contract for security
  - owner can stop transactions to prevent zero withdraw
  - owner can stop transactions to prevent withdraw with 0-balance
- **transferInternal**
  - user can transfer their balance into another user inside the bank
  - no need to move it to the mainnet wallet then sending it again to the user inside the system
- **getBankTotalBalance**
  - the bank managers can display the total balance of the bank
- **transferOwnership**
  - transfer the ownership of the system
  - control who can click the pause button
  - make it 2-step if possible
