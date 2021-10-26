from brownie import config, accounts, network, GiveCoin
from brownie.network import account
import os
from web3 import Web3
# from util_scripts import get_account
from scripts.util_scripts import get_account

# ----------------------------------------------------------------
# Code for deploying the smart contract
# ----------------------------------------------------------------

# Pre-requisites:
# Contracts are compiled through Brownie
# Network settings maintained in brownie-config.yaml
# Private Keys maintained in .env


def deploy_give_coin():

    account = get_account()
    print(account)

    if len(GiveCoin) > 0:
        GYV = GiveCoin[-1]
    else:
        GYV = GiveCoin.deploy(accounts[0], accounts[1], accounts[2], Web3.toWei(
            500000000, unit="ether"), 3846, {'from': account}, publish_source=config['networks'][network.show_active()].get('verify'))
        # print(GYV)

    print('After deploying:', len(GiveCoin))

    return GYV


def buy_tokens(GYV, account_index, eths):

    account = accounts[account_index]

    GYV.buyTokens(
        {'from': account, 'value': Web3.toWei(eths, unit='ether')}).wait(1)


def main():

    GYV = deploy_give_coin()

    print(GYV)
