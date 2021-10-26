# gyvchaincore
This project is all about creating a blockchain solution for charity-related crowdfunding efforts.  The project and ideas around our implementation, originated from a discussion we had as a project team while participating in a Monash University Bootcamp.  From there, the ideas for this project took shape.

# Overview

> Charity through GYVing, a blockchain cryptocurrency solution to transparent, low cost and instant charity  
> \- Peter Eng, Nobel Peace Prize Nominee 2021

GYV Chain is a platform that provides a layer 2 ERC-20 ethereum based blockchain solution for donors to directly share funds across the Internet to selected charity participants in a completely transparent, timely and economical way reducing the cost of typical charity middleman-admin, management and marketing, while providing GYV Chain donors a reward for engaging in the platform.

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

We laboured for many hours, downing many cups of coffee, losing many coins to the swear jar (literally) ... but in the end we got there.  We built the site from a website template and added in the bits and pieces we needed to accomplish the vision.

MetaMask integration with the Ethereum Testnet, our test wallets and the backend, all came together to make it work.  A little bit about the site and tools used, follows.

### Home Page

This is the landing page for the site, and briefly lays out what we're about.  As one descends the page, the why is explained/revealed, touching on the tokenomics, the roadmap and selected/highlighted mock charity campaigns one can donate to and of course a number of links and buttons directing the user/donor to the "GYV" page, where one can do what one has come to the site to do ... donate!!

Across the top of the page, one can select the different aspects mentioned above, including access to the Whitepaper itself.

![Oops, image not available](./images/gyv_chain_1.png "Gyv Chain Frontend")  

### GYV Page

The most important of all the pages!  The place where one can donate.  The page responsible for all the coffee drunk and coins lost!

The "Connect" button is where the magic happens, calling the various bits of JavaScript that allow for the interaction with MetaMask, the integration to Moralis then to the blockchain (Kovan Testnet in this case) and the call to the smart-contract processing the donation itself (see next section for example).

![Oops, image not available](./images/gyv_chain_2.png "Gyv Chain Frontend")  

### The Contract

The contract was deployed on Kovan and is viewable to anyone on the planet at the Kovan-specific etherscan address [here](https://kovan.etherscan.io/address/0x96F407d2DfD6B185d120e6d89171c9146721DF00).  Along with viewing the contract itself, every transaction and/or interaction (donations, setting up campaigns, etc.) can also be viewed.

The minting of $GYV was simulated upon deployment.  From the Whitepaper, the initial supply was $GYV400,000,000 to the various accounts which hold the various alloction of funds (see [this](https://kovan.etherscan.io/tx/0x4c16fb28a22df9dbca40fc2d7dd5649e2fdc5784062740b5a5752589ac686f48) transaction on Kovan's etherscan for the breakdown)

In order to interact the 

![Oops, image not available](./images/gyv_chain_5.png "Selecting the campaign")  

## Whitepaper

With any project around a blockchain platform, whether for real or a side-project, the whitepaper is, in our view, extremely important for a number of reasons.

- It allows the reader to understand the logic of the Project/Platform, the vision and what the project is trying to solve
- It clearly explains the tokenomics, integral to the smart-contract, without getting bogged down in the detail
- It highlights the next steps and roadmap for the platform and project

The current version of the whitepaper - always under review :) - is available [here](frontend/GYVweb1.1/resources/gyvchain_whitepaper_v1_1.pdf) or if you're having issues accessing it, here is the relative path: `frontend/GYVweb1.1/resources/gyvchain_whitepaper_v1_1.pdf`

## Tools used

### Remix - Solidity

Remix IDE allows developing, deploying and administering smart contracts for Ethereum like blockchains, including the ability to deploy them to an RPC network locally (using Ganache), or a Testnet such as Kovan (references in the document), Ropsten or Binance Smartchain.

### Moralis

Moralis provides a managed backend for blockchain projects. Automatically syncing the balances of your users into the database, allowing you to set up on-chain alerts, watch smart contract events, build indexes, and so much more. All features are accessed through an easy-to-use SDK or directly using their libraries (plugging in some good ol' JavaScript).

![Oops, image not available](./images/gyv_chain_3.png "Moralis Admin Console")  

### Brownie

Brownie is a Python-based development and testing framework for smart contracts targeting the Ethereum Virtual Machine.  It allows one to programmatically/automatically compile, deploy and test smart-contracts and compatible with all Ethereum Testnets already mentioned.

![Oops, image not available](./images/Brownie-config.png "Brownie config example")  

### OpenZeppelin

As part of the contract creation, we used OpenZeppelin's standardised contract library, which allowed us to just think about our own logic and not to worry about writing in additional protections and utilities.  
 - We used the ERC20 token standard, available on GitHub [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC20/ERC20.sol)
 - We used the re-entrancy guard utility token standard, also available on GitHub [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/utils/ReentrancyGuard.sol)

### Nicepage

For the website, we used Nicepage (learn more [here](https://nicepage.site/)) to create an initial template of what we wanted, into which we injected our Team's goodness, including the Whitepaper, the JavaScript interactions, the pages themselves, Moralis and MetaMask.

## Conclusion

### Challenges

Despite the tight time-constraints of this Project (all in full-time employment), we did limited testing of the ICO simulations, yet what was done, was successful.

The testing of *campaign creation*, *campaign approvals*, *donations* and then *concluding* those campaigns, transferring funds out to Charity addresses, was limited; those pesky ime-constraints again. It goes without saying then, that the testing we wanted to do with large amounts of ETH and GYV was just not possible, particularly because of the low supply of ETH. 

On that note, we were able to successfully create a Uniswap Liquidity Pool (Uniswap v3) and then swap ETH for GYV, but as mentioned, due to the shortage of GYV and low liquidity, we were not able to "go wild" and this limited testing with hundreds of addresses and/or with hundreds of thousands (heck, millions!) of GYV.

### What Next?

There is a lot of development work yet required for the frontend (HTML, CSS) and backend (JavaScript, MongoDB integration).  This is all required for some of the features we want to add on both sides of the equation, e.g. for donors and charities.  The contract needs more work, to finalise the tokenomics, iron out some of the kinks as well as make it more secure and inject some best-practice, not limited to the creation of a DAO. 

### Concluding thoughts

This particular project was pretty rewarding and that is a Team-wide conclusion!  Setting up this blockchain project, which seems at first glance to be fairly daunting, has not been at all. The varying passions this Team has for differing areas in life, have contributed well to the final result.

In the end, what we were able to do together has been superb.

## The Team!

Short intro into the Team involved in this little project.  We're a group with varying interests and careers, not specifically FinTech related, nor is the entire Team technically astute!  Having said that, the Team came together and contributed none-the-less.

- Andrew A. - the Neo
- Brian N. - the UXer
- Patrick K. - the Socialite
- Pete E. - the PM
- Sid T. - the contract Mad Hatter

# Acknowledgements and References

- Remix has been used as the IDE for this little project
- Ganache has also been used to help with the testing off-chain
- Brownie has been used to ease contract testing and deployment
- We made use of the Chainlink Faucet for the ETH used, find that [here](https://faucets.chain.link/kovan)
- For on-chain testing, we used the Kovan Testnet (more [here](https://kovan-testnet.github.io/website/))
- Learn all about OpenZeppelin and the standards of safety they provide at https://docs.openzeppelin.com but more specifically relating to ERC-20 [here](https://docs.openzeppelin.com/contracts/2.x/crowdsales)
- Ethereum Foundation needs to be acknowledged in general for their work, in their creation of their specific blockchain, allowing for the ecosystem to blossom as it currently has.
- Thanks to Trinity College, an organisation that has provided the training, which in turn has allowed for the creation of our project (as part of a Monash University Bootcamp).
