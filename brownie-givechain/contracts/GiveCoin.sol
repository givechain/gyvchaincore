// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GiveCoin is ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    address payable[] admins; // Address of the admin funds

    address payable upkeepFundsAddress;

    address payable donorFunds; // Address of the Campaign Funds

    uint256 weiRaised;

    uint256 rate;

    uint256 public numOfCampaigns;

    event CampaignCreated(uint256 indexed campaignId, uint256 campaignAmount);

    event CampaignApproved(uint256 indexed campaignId, uint256 campaignAmount);

    event Donated(uint256 indexed campaignId, uint256 pendingAmount);

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

    constructor(
        address payable _adminAddress, // Set it to Account 1
        address payable _campaignFundsAddress, // Set it to Account 2
        address payable _upkeepFundsAddress, // Set it to Account 3
        uint256 initial_supply,
        uint256 _rate
    ) public ERC20("GiveCoin", "GYV") {
        rate = _rate;

        uint256 mintToAdmins = initial_supply / 10; // 10% to Admins account
        uint256 mintToUpkeep = initial_supply / 10; // 10% to upkeep account

        uint256 mintForICO = (initial_supply * 30) / 100; // 30% to initial ICO

        // Initialise the admins array
        admins.push(_adminAddress);
        _mint(admins[0], mintToAdmins);

        // Set the campaignFundsAddress address - the address to which the Donors' tokens will be stored for the duration of the campaign
        donorFunds = _campaignFundsAddress;
        admins.push(donorFunds);
        _mint(donorFunds, mintForICO);

        upkeepFundsAddress = _upkeepFundsAddress; // Account 3 is the upkeep funds address
        _mint(upkeepFundsAddress, mintToUpkeep);

        _mint(address(this), mintForICO);
    }

    // function setAllowances(address payable _address) public onlyAdmins {
    //     _approve(address(this), _address, balanceOf(address(this)));
    // }

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

    function getWeiRaised() public view returns (uint256) {
        return weiRaised;
    }

    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return weiAmount.mul(rate);
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

        emit CampaignCreated(numOfCampaigns, _goal);

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

        emit CampaignApproved(_index, campaign.campaignGoal);
    }

    // ---------------------------------------------------------------------------------------------
    // Functions to donate funds to campaigns
    // ---------------------------------------------------------------------------------------------

    function buyTokens() public payable nonReentrant {
        uint256 weiAmount = msg.value;

        // @TODO: add validations - check CrowdSale.sol for reference

        // calculate token amount to be created
        uint256 tokenAmount = _getTokenAmount(weiAmount);

        // The contract needs to have those many tokens
        require(
            balanceOf(address(this)) > tokenAmount,
            "Not enough tokens in the contract"
        );

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _approve(address(this), msg.sender, tokenAmount);

        // transfer(msg.sender, tokenAmount);
        transferFrom(address(this), msg.sender, tokenAmount);
    }

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

        uint256 pendingFunds;

        if (campaign.collectedFunds <= campaign.campaignGoal) {
            pendingFunds = campaign.campaignGoal.sub(campaign.collectedFunds);
        } else {
            pendingFunds = 0;
        }

        emit Donated(_index, pendingFunds);
    }

    function closeCampaign(uint256 _index) public payable onlyAdmins {
        Campaign storage campaign = mapCampaigns[_index];

        require(
            campaign.campaignStatus == CAMPAIGN_STATE.OPEN,
            "Campaign Cant be closed from this status"
        );

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
