// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";

import "./Campaign.sol";

contract CampaignsFactory is ERC20, ERC20Detailed {
    address payable[] admins;
    address payable owner = msg.sender;

    Campaign[] campaignsArray;

    struct donor {
        address payable donorAddress;
        uint256 donatedAmount;
    }

    modifier onlyAdmins() {
        bool isAdmin;

        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == msg.sender) {
                isAdmin = true;
            }
        }

        require(isAdmin, "Accessible only to admins");
        _;
    }

    constructor(uint256 initial_supply)
        public
        ERC20Detailed("CampaignToken", "CMPG", 18)
    {
        // Initialise the admins array
        admins.push(0x4331FB28b46E926787641003D8888625d854b6D6);

        uint256 mintToEachAdmin = initial_supply / admins.length;

        for (uint256 i; i < admins.length; i++) {
            _mint(admins[i], mintToEachAdmin);
        }
    }

    // NOT USED ANYWHERE - Just copied from the activities code for reference
    function mint(address recipient, uint256 amount) public onlyAdmins {
        _mint(recipient, amount);
    }

    // ---------------------------------------------------------------------------------------------
    // Functions to retrieve data
    // ---------------------------------------------------------------------------------------------
    function getCampaignAtIndex(uint256 _index)
        public
        view
        returns (
            address,
            string memory,
            Campaign.CAMPAIGN_STATE,
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        require(_index < campaignsArray.length);
        return Campaign(address(campaignsArray[_index])).getDetails();
        // return (campaignsArray[_index]);
    }

    function getCampaignDetails(address _contractAddress)
        internal
        view
        returns (
            address payable,
            string memory,
            Campaign.CAMPAIGN_STATE,
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        return Campaign(address(_contractAddress)).getDetails();
    }

    function getCampaignsArray() public view returns (Campaign[] memory) {
        return campaignsArray;
    }

    function getDonorsForCampaign(address _contractAddress)
        public
        view
        returns (address payable[] memory, uint256[] memory)
    {
        Campaign campaign = Campaign(address(_contractAddress));
        return (campaign.getDonors());
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // ---------------------------------------------------------------------------------------------
    // Functions to interact with campaigns
    // ---------------------------------------------------------------------------------------------

    function createCampaignContract(
        string memory _name,
        string memory _url,
        uint256 _due,
        uint256 _goal
    ) public {
        Campaign campaign = new Campaign(msg.sender, _name, _url, _due, _goal);
        campaignsArray.push(campaign);
    }

    function approveCampaign(address _contractAddress, bool _approve)
        public
        onlyAdmins
    {
        Campaign campaign = Campaign(address(_contractAddress));
        campaign.approveCampaign(_approve);
    }

    function donate(address _contractAddress) public payable {
        Campaign campaign = Campaign(address(_contractAddress));

        campaign.donate(msg.sender, msg.value);
    }

    function closeCampaign(address _contractAddress) public onlyAdmins {
        (
            address payable campaignOwner,
            ,
            ,
            ,
            uint256 dueDate,
            uint256 campaignGoal,
            uint256 collectedFunds
        ) = getCampaignDetails(_contractAddress);

        require(
            dueDate < now || collectedFunds >= campaignGoal,
            "Campaign cant be closed"
        );

        // Transfer funds to the campaignowners address
        campaignOwner.transfer(collectedFunds);

        // Get all the donors to this fund

        (
            address payable[] memory donors,
            uint256[] memory amounts
        ) = getDonorsForCampaign(_contractAddress);

        for (uint256 i; i < donors.length; i++) {
            address payable donorAddress = donors[i];
            uint256 amount = amounts[i];

            mint(donorAddress, amount);
        }
    }
}
