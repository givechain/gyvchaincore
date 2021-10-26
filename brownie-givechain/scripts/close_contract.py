from brownie import config, accounts, network, GiveCoin
from brownie.network import account
import os
from web3 import Web3
import time
from scripts.util_scripts import get_account

# ----------------------------------------------------------------
# Code for closing the campaigns
# ----------------------------------------------------------------

# This script will be run on a periodic basis.
# The code will get a list of all open campaigns, check which ones can be closed on basis
#   of due date or goals achieved

# Pre-requisites
# Network settings maintained in brownie-config.yaml
# Private Keys maintained in .env


def main():

    account = get_account()
    # print(account)

    if len(GiveCoin) == 0:
        # No deployed contracts
        return

    # Take the latest deployed contract
    GVY = GiveCoin[-1]
    # print(GVY.address)

    for i in range(GVY.numOfCampaigns()):
        owner, name, uri, due_date_unix, target, collected, status = GVY.getCampaignAtIndex(
            i)

        # Only process the contracts which are open
        if status != 2:
            continue

        close_contract = False

        if time.time() >= due_date_unix:

            print(
                f'Contract {name} will be closed because it has passed its due date')
            close_contract = True

        if collected > target:
            print(
                f'Contract {name} will be closed because it has met its target funds')
            close_contract = True

        if close_contract:

            GVY.closeCampaign(i, {'from': account}).wait(1)
