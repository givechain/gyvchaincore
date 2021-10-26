# Brownie Developments for Givechain 

## Overview

Brownie is a Python-based development and testing framework for smart contracts targeting the Ethereum Virtual Machine. 

For more details on Brownie, please refer to the documentation available at [Brownie — Brownie 1.17.0 documentation](https://eth-brownie.readthedocs.io/en/stable/index.html)

## Configurations

In this project, Brownie was used to deploy and interact with the GiveCoin smart contract on Ganache and Kovan networks. 

Brownie Config file: 

> ![Brownie Config](Images/Brownie-config.png)

## Python scripts

* [deploy.py](scripts/deploy.py) - This script is used for deploying the GiveCoin contracts on the networks configured in brownie-config.yaml file

* [close_contract.py](scripts/close_contract.py) - This script is run periodically, and used for closing the open campaigns which are due, or which have met the campaign goals 