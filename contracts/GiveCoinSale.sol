pragma solidity ^0.5.0;

import "./GiveCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";

contract GiveCoinSale is Crowdsale, MintedCrowdsale {
    constructor(
        uint256 rate, // rate in TKNbits
        address payable wallet, // sale beneficiary
        GiveCoin token // the GiveCoin itself that the GiveCoinSale will work with
    ) public Crowdsale(rate, wallet, token) {}

    function mintTestTokens() public payable {
        _deliverTokens(
            0x4331FB28b46E926787641003D8888625d854b6D6,
            500 * 10**18
        ); // Account 1
        _deliverTokens(
            0xeed0056f8DCDf247BcaA54d1AF159a3616CBb1C9,
            500 * 10**18
        ); // Account 5
        _deliverTokens(
            0x16783e61BCB3705AF4c4aee0ADE7165DC7bC4B41,
            500 * 10**18
        ); // Account 6
        // _deliverTokens(0x5DC35De626043B243B25c39BE4DE4c038085A922, 500 * 10**18);     // Account 7
        // _deliverTokens(0xd477c6a9aA8Ca58b6F48bD49D4Fc13308252c0b9, 500 * 10**18);     // Account 8
    }
}

contract GiveCoinSaleDeployer {
    address public giveCoin_sale_address;
    address public token_address;
    uint256 rate = 3846; // 1 USD = 0.00026 ETH = 260000000000000 Wei

    constructor(
        address payable wallet, // this address will receive all Ether raised by the sale
        uint256 initial_supply
    ) public {
        // create the GiveCoin contract and keep its address handy
        GiveCoin token = new GiveCoin(initial_supply);
        token_address = address(token);

        // create the GiveCoinSale and tell it about the token
        GiveCoinSale giveCoin_sale = new GiveCoinSale(rate, wallet, token);
        giveCoin_sale_address = address(giveCoin_sale);

        // // set the address of the GiveCoinSale contract in the Token contract
        // token.setSaleContractAddress(address(giveCoin_sale));

        // make the GiveCoinSale contract a minter, then have the GiveCoinSaleDeployer renounce its minter role
        token.addMinter(giveCoin_sale_address);
        token.addMinter(msg.sender);
        token.renounceMinter();

        // Only for the demo
        giveCoin_sale.mintTestTokens();
    }
}
