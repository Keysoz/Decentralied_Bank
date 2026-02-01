<!-- ## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
``` -->
# 🏦 Decentralized Banking System

A robust, professional-grade banking smart contract built with **Solidity** and the **Foundry** development framework. This project demonstrates core banking functionalities including deposits, withdrawals, internal transfers, and ownership management, all protected by a pause-able circuit breaker.

## 🛠 Features
- **Secure Deposits/Withdrawals**: Implements the Checks-Effects-Interactions (CEI) pattern to prevent reentrancy.
- **Internal Transfers**: Gas-efficient balance updates between bank users.
- **Circuit Breaker**: Owner can pause all financial transactions in case of an emergency using OpenZeppelin's `Pausable`.
- **Advanced Testing**: 100% logic coverage using Foundry (Fuzz testing, event checking, and state-warping).
- **Professional NatSpec**: Fully documented interfaces for better developer experience and automatic documentation generation.

## 🏗 Project Structure
- `src/`: Core logic (Bank.sol, IBank.sol, Errors.sol).
- `test/`: Comprehensive test suite (Bank.t.sol).
- `script/`: Deployment automation.
- `lib/`: External dependencies (OpenZeppelin, Forge-std).

## 🚀 Getting Started

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed.

### Installation
1. Clone the repo:
   ```bash
   git clone [https://github.com/your-username/decentralized-bank.git](https://github.com/your-username/decentralized-bank.git)
   cd decentralized-bank