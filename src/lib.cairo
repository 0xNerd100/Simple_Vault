use starknet::ContractAddress;

#[starknet::interface]
pub trait ISimpleVault<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState, shares: u256);
    fn get_user_balance(self: @TContractState, account: ContractAddress) -> u256;
}


#[starknet::contract]
mod HelloStarknet {
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{get_caller_address, get_contract_address};
    use super::ContractAddress;

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        total_supply: u256,
        balance_of: Map<ContractAddress, u256>,
    }
    #[constructor]
    fn constructor(ref self: ContractState, token: ContractAddress) {
        self.token.write(IERC20Dispatcher { contract_address: token });
    }

    #[generate_trait]
    impl PrivateFunctions of PrivateFunctionsTrait {
        fn _mint(ref self: ContractState, to: ContractAddress, share: u256) {
            let ts = self.total_supply.read(); //total supply
            let bs = self.balance_of.read(to);  //balance of user
            self.total_supply.write(ts + share);

            self.balance_of.write(to, bs + share);
        }

        fn _burn(ref self: ContractState, to: ContractAddress, share: u256) {
            let ts = self.total_supply.read(); //total supply
            let bs = self.balance_of.read(to);  //balance of user
            self.total_supply.write(ts - share);

            self.balance_of.write(to, bs - share);
        }
    }

    #[abi(embed_v0)]
    impl SimpleVaultImpl of super::ISimpleVault<ContractState> {
        /// Deposit tokens into the vault
        fn deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            let this = get_contract_address();
            let mut shares = 0;
            if self.total_supply.read() == 0 {
                shares = amount; // initial deposit, 1:1
            } else {
                shares = (amount * self.total_supply.read()) / self.token.read().balance_of(this); // proportional
            }
            PrivateFunctions::_mint(ref self, caller, shares); // mint shares to user
            self.token.read().transfer_from(caller, this, amount); // transfer tokens to vault
        }
        fn withdraw(ref self: ContractState, shares: u256) {
            let caller = get_caller_address();
            let this = get_contract_address();
            let amount = (shares * self.token.read().balance_of(this)) / self.total_supply.read(); // proportional
            PrivateFunctions::_burn(ref self, caller, shares); // burn shares from user
            self.token.read().transfer(caller, amount); // transfer tokens to user
        }

        fn get_user_balance(self: @ContractState, account: ContractAddress) -> u256 {
            self.balance_of.read(account)  
        }
    }
}
