# gyvchaincore
This project is all about creating a blockchain solution for charity-related crowdfunding efforts.  The project and ideas around our implementation, originated from a discussion we had as a project team while participating in a Monash University Bootcamp.  From there, the ideas for this project took shape.

# Overview

\- PETE - !!!!!!!!!!!!
The overview of what we were trying to accomplish

## Instructions

Here are a few little points on how to prep for, firing up the home page and then donating!

- "Download" this very project from GitHub (just click the download button)
- Open up the page with your preferred browser (Chromium is recommended)
  - `./frontend/GYVweb1.1/Home.html`
- Prepare for a donation by setting up MetaMask (a secure wallet, easy to use)
  - MetaMask has as great starter article [here](https://metamask.zendesk.com/hc/en-us/articles/360015489531-Getting-started-with-MetaMask)
  - Add Ethereum to your wallet (NOTE: this needs to be done on the Kovan Testnet using what is known as a faucet, a.k.a a tap :)
  - Find the faucet [here](https://faucets.chain.link/kovan)
  - Learn more about the great things the Kovan Team are doing [here](https://kovan-testnet.github.io/website/)
- In order to donate, one would need to go to Uniswap (NOTE: make sure your MetaMask is connected to Kovan) and swap the Ethereum you've just added to your wallet, for GYV.  
- Now you're in a position to donate!!!
- Below is all you need to know about the Frontend, and donating to your cause!

![Oops, image not available](./images/gyv_chain_4.png "Gyv Chain Frontend")  

## Frontend

### Home Page
Blah.

![Oops, image not available](./images/gyv_chain_1.png "Gyv Chain Frontend")  

### GYV Page
Blah.

![Oops, image not available](./images/gyv_chain_2.png "Gyv Chain Frontend")  


## Whitepaper

With any project around a blockchain platform, whether for real or a side-project, the whitepaper is, in our view, extremely important for a number of reasons.

- It allows the reader to understand the logic of the Project/Platform, the vision and what the project is trying to solve
- It clearly explains the tokenomics, integral to the smart-contract, without getting bogged down in the detail
- It highlights the next steps and roadmap for the platform and project

The current version of the whitepaper - always under review :) - is available [here](frontend/GYVweb1.1/resources/gyvchain_whitepaper_v1_1.pdf) or if you're having issues accessing it, here is the relative path: `frontend/GYVweb1.1/resources/gyvchain_whitepaper_v1_1.pdf`

## Tools used

### Remix - Solidity

Remix IDE allows developing, deploying and administering smart contracts for Ethereum like blockchains, including the ability to deploy them to an RPC network locally (using Ganache), or a Testnet such as Kovan (references in the document), Ropsten or Binance Smartchain.

### Morallis.io

Moralis provides a managed backend for blockchain projects. Automatically syncing the balances of your users into the database, allowing you to set up on-chain alerts, watch smart contract events, build indexes, and so much more. All features are accessed through an easy-to-use SDK or directly using their libraries (plugging in some good ol' JavaScript).

![Oops, image not available](./images/gyv_chain_3.png "Moralis Admin Console")  

### Brownie - Python framework

Brownie is a Python-based development and testing framework for smart contracts targeting the Ethereum Virtual Machine.

### OpenZeppelin

As part of the contract creation, we used OpenZeppelin's standardised contract library, which allowed us to just think about our own logic and not to worry about writing in additional protections and utilities.  
 - We used the ERC20 token standard, available on GitHub [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC20/ERC20.sol)
 - We used the re-entrancy guard utility token standard, also available on GitHub [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/utils/ReentrancyGuard.sol)

## Conclusions/Concluding thoughts 

Blah

# Acknowledgements and References
- Remix has been used as the IDE for this little project
- Ganache has also been used to help with the testing off-chain
- I made use of the Chainlink Faucet for the ETH I used in this project, find that [here](https://faucets.chain.link/kovan)
- For the on-chain testing, we used the Kovan Testnet (more [here](https://kovan-testnet.github.io/website/))
- Learn all about OpenZeppelin and the standards of safety they provide at https://docs.openzeppelin.com but more specifically relating to ERC-20 [here](https://docs.openzeppelin.com/contracts/2.x/crowdsales)
- Ethereum Foundation needs to be acknowledged for their work, creating their blockchain, which allows for the deplyment and interaction with "smart-contracts"
- Thanks to Trinity College, an organisation that has provided the training which has allowed for the accomplishment of this demo (as part of a Monash University Bootcamp)

