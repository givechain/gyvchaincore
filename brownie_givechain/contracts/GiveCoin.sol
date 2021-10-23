// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GiveCoin is ERC20 {
    address payable[] admins; // Address of the admin funds

    address payable upkeepFundsAddress;

    address payable donorFunds; // Address of the Campaign Funds

    uint256 public numOfCampaigns;

    struct Campaign {
        address payable campaignOwner;
        string campaignName;
        string campaignURI;
        uint256 dueDate;
        uint256 campaignGoal;
        uint256 collectedFunds;
        CAMPAIGN_STATE campaignStatus;
        uint256 numOfDonors;
    }

    mapping(uint256 => Campaign) private mapCampaigns;

    struct Donor {
        address donorAddress;
        uint256 donorAmount;
    }

    mapping(uint256 => Donor[]) private mapDonors;

    enum CAMPAIGN_STATE {
        APPROVAL,
        REJECTED,
        OPEN,
        CLOSED
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

    constructor(uint256 initial_supply) public ERC20("GiveCoin", "GIV") {
        uint256 mintToAdmins = initial_supply / 10; // 10% to Admins account
        uint256 mintToUpkeep = initial_supply / 10; // 10% to upkeep account
        // uint mintToContract = initial_supply * 10**18 * 30 / 100 ;      // 30% to ICO Wallet

        // Initialise the admins array
        admins.push(0x4331FB28b46E926787641003D8888625d854b6D6); // Account 1 is the admin - this will receive 10% of donations
        _mint(admins[0], mintToAdmins);

        // Set the donorFunds address - the address to which the Donors' tokens will be stored for 6 months
        donorFunds = 0xC1a8780dC833A8Dd8B0760b4c8052ADDFCD0f979; // Account 2 is the Campaign Fund's Wallet address
        admins.push(donorFunds);

        upkeepFundsAddress = 0x21C58A83a9CaF43C13D399ee98490161d9B212DB; // Account 3 is the upkeep funds address
        _mint(upkeepFundsAddress, mintToUpkeep);
    }

    // ---------------------------------------------------------------------------------------------
    // Functions to retrieve data
    // ---------------------------------------------------------------------------------------------

    function getCampaignAtIndex(uint256 _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            CAMPAIGN_STATE
        )
    {
        require(_index < numOfCampaigns);

        Campaign memory campaign = mapCampaigns[_index];

        return (
            campaign.campaignOwner,
            campaign.campaignName,
            campaign.campaignURI,
            campaign.dueDate,
            campaign.campaignGoal,
            campaign.collectedFunds,
            campaign.campaignStatus
        );
    }

    function getDonorsForCampaign(uint256 _index)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        require(_index < numOfCampaigns);

        Donor[] memory donorsArray = mapDonors[_index];

        address[] memory donorAddresses = new address[](donorsArray.length);
        uint256[] memory donorAmount = new uint256[](donorsArray.length);

        for (uint256 i; i < donorsArray.length; i++) {
            donorAddresses[i] = donorsArray[i].donorAddress;
            donorAmount[i] = donorsArray[i].donorAmount;
        }

        return (donorAddresses, donorAmount);
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
        Campaign memory campaign = Campaign({
            campaignOwner: msg.sender,
            campaignName: _name,
            campaignURI: _url,
            dueDate: (now + (_due * 1 days)),
            campaignGoal: _goal,
            collectedFunds: 0,
            campaignStatus: CAMPAIGN_STATE.APPROVAL,
            numOfDonors: 0
        });

        mapCampaigns[numOfCampaigns] = campaign;

        numOfCampaigns++;
    }

    function approveCampaign(uint256 _index, bool _approve) public onlyAdmins {
        require(_index < numOfCampaigns);

        Campaign storage campaign = mapCampaigns[_index];

        if (_approve) {
            campaign.campaignStatus = CAMPAIGN_STATE.OPEN;
        } else {
            campaign.campaignStatus = CAMPAIGN_STATE.REJECTED;
        }
    }

    // ---------------------------------------------------------------------------------------------
    // Functions to donate funds to campaigns
    // ---------------------------------------------------------------------------------------------

    function donate(uint256 _index, uint256 _amount) public payable {
        require(_index < numOfCampaigns);

        uint256 adminFees = _amount / 10;

        // Update the donors array for the campaign
        Donor[] storage donorsArray = mapDonors[_index];
        donorsArray.push(Donor(msg.sender, (_amount)));

        // Update the collected funds in the campaign
        Campaign storage campaign = mapCampaigns[_index];
        campaign.collectedFunds += _amount - adminFees;
        campaign.numOfDonors++;

        // transfer the funds to the admin and the campaign funds wallets

        // 90% of the funds will be transferred to the campaignFunds variable
        // 10% of the funds will be transferred to the donorFunds address
        transfer(admins[0], adminFees);
        transfer(donorFunds, _amount - adminFees);
    }

    function closeCampaign(uint256 _index) public payable onlyAdmins {
        Campaign storage campaign = mapCampaigns[_index];

        require(
            campaign.dueDate <= now ||
                campaign.collectedFunds >= campaign.campaignGoal
        );

        // Transfer the funds to campaignOwner - Transferring GIV for now.
        // @TODO: Convert GIV to USD/ETH by calling UniSwap

        transfer(campaign.campaignOwner, campaign.collectedFunds);

        // Update the campaign status
        campaign.campaignStatus = CAMPAIGN_STATE.CLOSED;
    }
}
