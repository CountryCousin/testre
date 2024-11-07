

    use testre::simple_vault::{ ISimpleVaultDispatcher, ISimpleVaultDispatcherTrait};
    use testre::erc20::{
        IERC20DispatcherTrait as IERC20DispatcherTrait_token,
        IERC20Dispatcher as IERC20Dispatcher_token
    }; 
 
    use starknet::ContractAddress;
   
    use snforge_std::{declare, ContractClassTrait, DeclareResultTrait,start_cheat_caller_address};
    

const NAME :felt252 ='myToken';
const DECIMALS: felt252 = 18;
const INITIAL_SUPPLY:felt252=100_000_000 ;
const SYMBOL:felt252 ='tkm';

    fn deploy(name: ByteArray,args: Array<felt252>) -> ContractAddress {
        let contract = declare(name).unwrap().contract_class();
        let (contract_address, _) = contract.deploy(@args).unwrap();
        contract_address
    }
    
    #[test]
    fn test_deposit() {
        let caller = starknet::contract_address_const::<'caller'>();
        let erc20_args =array!['test',NAME,DECIMALS,INITIAL_SUPPLY,SYMBOL];
        let address = deploy("erc20",erc20_args);
        let token_dispatcher =IERC20Dispatcher_token { contract_address: address};
        let vault_address = deploy("SimpleVault",array![address.try_into().unwrap()]);
        let dispatcher = ISimpleVaultDispatcher {contract_address : vault_address};
        // Approve the vault to transfer tokens on behalf of the caller
        let amount: felt252 = 10.into();
        token_dispatcher.approve(vault_address.into(), amount);
        start_cheat_caller_address(vault_address,caller);

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

    // #[test]
    // fn test_deposit_withdraw() {
    //     let caller = contract_address_const::<'caller'>();
    //     let (dispatcher, vault_address, token_dispatcher) = deploy();

    //     // Approve the vault to transfer tokens on behalf of the caller
    //     let amount: felt252 = 10.into();
    //     token_dispatcher.approve(vault_address.into(), amount);
    //     set_contract_address(caller);
    //     set_account_contract_address(vault_address);

    //     // Deposit tokens into the vault
    //     let amount: u256 = 10.into();
    //     dispatcher.deposit(amount);
    //     dispatcher.withdraw(amount);

    //     // Check balances of user in the vault after withdraw
    //     let balance_of_caller = dispatcher.user_balance_of(caller);

    //     assert_eq!(balance_of_caller, 0.into());
    // }
