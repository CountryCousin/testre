mod tests {
    use simplevault::simple_vault::{SimpleVault, ISimpleVaultDispatcher, ISimpleVaultDispatcherTrait,};
    use simplevault::erc20::{
        IERC20DispatcherTrait as IERC20DispatcherTrait_token,
        IERC20Dispatcher as IERC20Dispatcher_token
    }; 
    use starknet::testing::{set_contract_address, set_account_contract_address};
    use starknet::{
        ContractAddress, SyscallResultTrait, syscalls::deploy_syscall, contract_address_const
    };

    const token_name: felt252 = 'myToken';
    const decimals: u8 = 18;
    const initial_supply: felt252 = 100000;
    const symbols: felt252 = 'mtk';

    fn deploy() -> (ISimpleVaultDispatcher, ContractAddress, IERC20Dispatcher_token) {
        let _token_address: ContractAddress = contract_address_const::<'token_address'>();
        let caller = contract_address_const::<'caller'>();

        let (token_contract_address, _) = deploy_syscall(
            simplevault::erc20::erc20::TEST_CLASS_HASH.try_into().unwrap(),
            caller.into(),
            array![caller.into(), 'myToken', '8', '1000'.into(), 'MYT'].span(),
            false
        )
            .unwrap_syscall();

        let (contract_address, _) = deploy_syscall(
            SimpleVault::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            array![token_contract_address.into()].span(),
            false
        )
            .unwrap_syscall();

        (
            ISimpleVaultDispatcher { contract_address },
            contract_address,
            IERC20Dispatcher_token { contract_address: token_contract_address }
        )
    }

    #[test]
    fn test_deposit() {
        let caller = contract_address_const::<'caller'>();
        let (dispatcher, vault_address, token_dispatcher) = deploy();

        // Approve the vault to transfer tokens on behalf of the caller
        let amount: felt252 = 10.into();
        token_dispatcher.approve(vault_address.into(), amount);
        set_contract_address(caller);

        // Deposit tokens into the vault
        let amount: u256 = 10.into();
        let _deposit = dispatcher.deposit(amount);
        println!("deposit :{:?}", _deposit);

        // Check balances and total supply
        let balance_of_caller = dispatcher.user_balance_of(caller);
        let total_supply = dispatcher.contract_total_supply();

        assert_eq!(balance_of_caller, amount);
        assert_eq!(total_supply, amount);
    }

    #[test]
    fn test_deposit_withdraw() {
        let caller = contract_address_const::<'caller'>();
        let (dispatcher, vault_address, token_dispatcher) = deploy();

        // Approve the vault to transfer tokens on behalf of the caller
        let amount: felt252 = 10.into();
        token_dispatcher.approve(vault_address.into(), amount);
        set_contract_address(caller);
        set_account_contract_address(vault_address);

        // Deposit tokens into the vault
        let amount: u256 = 10.into();
        dispatcher.deposit(amount);
        dispatcher.withdraw(amount);

        // Check balances of user in the vault after withdraw
        let balance_of_caller = dispatcher.user_balance_of(caller);

        assert_eq!(balance_of_caller, 0.into());
    }
}