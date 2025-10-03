# Simple Vault Contract

A simple vault contract implementation in Cairo for Starknet that allows users to deposit and withdraw ERC20 tokens while managing shares proportionally.

## Overview

Simple Vault is a smart contract that accepts ERC20 token deposits and mints shares to depositors based on their contribution. Users can later burn their shares to withdraw their proportional amount of tokens from the vault. This is a fundamental DeFi primitive similar to vault patterns used in yield aggregators.

## Features

- **Deposit**: Deposit ERC20 tokens and receive proportional shares
- **Withdraw**: Burn shares to withdraw your proportional amount of tokens
- **Share-based Accounting**: Fair distribution based on deposit timing and amount
- **Balance Tracking**: Query user balance of shares at any time
- **ERC20 Compatible**: Works with any standard ERC20 token on Starknet

## How It Works

1. **First Deposit**: When the vault is empty, shares minted equal the amount deposited (1:1 ratio)
2. **Subsequent Deposits**: Shares = (deposit_amount × total_shares) / total_vault_balance
3. **Withdrawals**: Token amount = (shares_to_burn × total_vault_balance) / total_shares

## Project Structure

```
simple_vault/
├── src/
│   └── lib.cairo          # Main contract implementation
├── Scarb.toml             # Project configuration
└── README.md              # This file
```

## Prerequisites

- [Scarb](https://docs.swmansion.com/scarb/) - Cairo package manager
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/) - For sncast CLI
- A funded Starknet Sepolia account

## Installation

1. Clone the repository:

```bash
git clone <your-repo-url>
cd simple_vault
```

2. Build the project:

```bash
scarb build
```

## Development Commands

### Format Code

```bash
scarb fmt
```

### Build Contract

```bash
scarb build
```

**Example Output:**

```
scarb build
   Compiling simple_vault v0.1.0 (/mnt/k/simple_vault/Scarb.toml)
    Finished `release` profile target(s) in 61 seconds
```

### Run Tests

```bash
scarb test
```

## Deployment Guide

### Step 1: Create Account

Create a new Starknet account for deployment:

```bash
sncast account create \
    --network=sepolia \
    --name=sepolia
```

**Example Output:**

```
Success: Account created

Address: 0x05bf322573459ebea2b9a969ad4571497bf40ab9608d8ee60f7a8c3d21309532

Account successfully created but it needs to be deployed. The estimated deployment fee is 0.002890272015816640 STRK. Prefund the account to cover deployment transaction fee

After prefunding the account, run:
sncast account deploy --network sepolia --name sepolia

To see account creation details, visit:
account: https://sepolia.starkscan.co/contract/0x05bf322573459ebea2b9a969ad4571497bf40ab9608d8ee60f7a8c3d21309532
```

> **Note**: Before deploying, you need to fund your account with STRK tokens. You can get testnet tokens from the [Starknet Sepolia Faucet](https://starknet-faucet.vercel.app/).

### Step 2: Deploy Account

Deploy your account to Sepolia:

```bash
sncast account deploy \
    --network sepolia \
    --name sepolia \
    --silent
```

**Example Output:**

```
Success: Account deployed

Transaction Hash: 0x5bbe1307f141b938a4d3268b1a927e10559bc13abdcf68d5fec79de86814e7f

To see account deployment details, visit:
transaction: https://sepolia.starkscan.co/tx/0x05bbe1307f141b938a4d3268b1a927e10559bc13abdcf68d5fec79de86814e7f
```

### Step 3: Declare Contract

Declare your contract to get the class hash:

```bash
sncast --account=sepolia declare \
    --contract-name=SimpleVault \
    --network=sepolia
```

**Example Output:**

```
   Compiling simple_vault v0.1.0 (/mnt/k/simple_vault/Scarb.toml)
    Finished `release` profile target(s) in 61 seconds
Success: Declaration completed

Class Hash:       0x6913b1295a0604c5acb041abd48508f780b4e32235353b0dd18a818fd99aade
Transaction Hash: 0x382ee89e6af46a3a8bab71258901236e184b588a960f0df6b5942a1975cc9e

To see declaration details, visit:
class: https://sepolia.starkscan.co/class/0x06913b1295a0604c5acb041abd48508f780b4e32235353b0dd18a818fd99aade
transaction: https://sepolia.starkscan.co/tx/0x00382ee89e6af46a3a8bab71258901236e184b588a960f0df6b5942a1975cc9e
```

### Step 4: Deploy Contract Instance

Deploy the contract with a constructor parameter (ERC20 token address):

```bash
sncast --account=sepolia deploy \
--class-hash=0x6913b1295a0604c5acb041abd48508f780b4e32235353b0dd18a818fd99aade \
--constructor-calldata=0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 \
--network=sepolia
```

**Example Output:**

```
Success: Deployment completed

Contract Address: 0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449
Transaction Hash: 0x074b083c53fadb16f3fc65f13893ef6524a6df3a063ced434eca812492980085

To see deployment details, visit:
contract: https://sepolia.starkscan.co/contract/0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449
transaction: https://sepolia.starkscan.co/tx/0x074b083c53fadb16f3fc65f13893ef6524a6df3a063ced434eca812492980085
```

> **Note**: The constructor parameter is the ERC20 token address you want to use with the vault. In this example, we used ETH token: `0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7`

## Common ERC20 Token Addresses (Sepolia)

- **ETH**: `0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7`
- **STRK**: `0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d`

## Interacting with the Contract

### Deposit Tokens

```bash
sncast --account=sepolia invoke \
--contract-address=0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449 \
--function=deposit \
--calldata=1000000000000000000 \
--network=sepolia
```

> **Note**: Make sure to approve the vault contract to spend your tokens first!

### Withdraw Tokens

```bash
sncast --account=sepolia invoke \
--contract-address=0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449 \
--function=withdraw \
--calldata=500000000000000000 \
--network=sepolia
```

### Check User Balance

```bash
sncast --account=sepolia call \
--contract-address=0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449 \
--function=get_user_balance \
--calldata=0x05bf322573459ebea2b9a969ad4571497bf40ab9608d8ee60f7a8c3d21309532 \
--network=sepolia
```

## Contract Interface

```cairo
#[starknet::interface]
pub trait ISimpleVault<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState, shares: u256);
    fn get_user_balance(self: @TContractState, account: ContractAddress) -> u256;
}
```

## Live Deployment (Sepolia Testnet)

- **Contract Address**: `0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449`
- **Class Hash**: `0x6913b1295a0604c5acb041abd48508f780b4e32235353b0dd18a818fd99aade`
- **Token**: ETH (`0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7`)

[View on Starkscan](https://sepolia.starkscan.co/contract/0x0225b58e699ff8668c63ae661b6705360ee0a2f69982d9122524636011387449)

## Security Considerations

⚠️ **This is a simple educational contract and has not been audited. Do not use in production without proper security review.**

Potential improvements:

- Add reentrancy guards
- Implement pausable functionality
- Add access controls for admin functions
- Consider rounding issues in share calculations
- Add minimum deposit/withdrawal amounts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Resources

- [Starknet Documentation](https://docs.starknet.io/)
- [Cairo Book](https://book.cairo-lang.org/)
- [Starknet Foundry Book](https://foundry-rs.github.io/starknet-foundry/)
- [OpenZeppelin Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)

## Contact

For questions or support, please open an issue in the repository.

---

**Built with Cairo for Starknet** �
