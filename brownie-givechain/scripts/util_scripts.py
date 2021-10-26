from brownie import accounts, network, config
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ['development', 'ganache-local']

DECIMALS = 18
STARTING_PRICE = 2000


def get_account():

    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    else:
        _accounts = []
        _accounts += [accounts.add(config['wallets']['from_key'])]
        _accounts += [accounts.add(config['wallets']['from_key_1'])]
        _accounts += [accounts.add(config['wallets']['from_key_2'])]
        # print(_accounts[0])
        return _accounts[0]
