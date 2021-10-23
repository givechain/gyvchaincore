from brownie import config, accounts, network
from brownie.network import account


def deploy_give_coin():

    account = accounts[0]
    for account in range(len(accounts)):
        print(accounts[account])
    # print(account)


def main():

    deploy_give_coin()
