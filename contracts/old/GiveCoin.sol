pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Mintable.sol";

// import "./Campaign.sol";
import "./GiveCoinSale.sol";

contract GiveCoin is ERC20, ERC20Detailed, ERC20Mintable {
    
    address payable[] admins;           // Address of the admin funds  
    // address payable owner = msg.sender;
    address payable donorFunds;         // Address of the Campaign Funds 
    
    uint public numOfCampaigns;

    struct Campaign {
        address payable campaignOwner ;
        string campaignName ;
        string  campaignURI ;
        uint  dueDate ;
        uint  campaignGoal ;
        uint  collectedFunds ;
        CAMPAIGN_STATE  campaignStatus ;
        uint  numOfDonors ;
    }
    
    mapping (uint => Campaign) private mapCampaigns;
    
    struct Donor {
        address donorAddress;
        uint donorAmount;
    }
    
    mapping (uint => Donor[]) private mapDonors;
    
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
    
    constructor(uint256 initial_supply) public 
        ERC20Detailed("GiveCoin", "GIV", 18)
    {
        // Initialise the admins array
        admins.push(0x4331FB28b46E926787641003D8888625d854b6D6);    // Account 1 is the admin - this will receive 10% of donations 
        
        // Set the donorFunds address - the address to which the Donors' tokens will be stored for 6 months
        donorFunds = 0xC1a8780dC833A8Dd8B0760b4c8052ADDFCD0f979 ;     // Account 2 is the Campaign Fund's Wallet address 
        
    }
    
    // ---------------------------------------------------------------------------------------------    
    // Functions to retrieve data 
    // ---------------------------------------------------------------------------------------------

    function getCampaignAtIndex(uint _index) public view 
        returns (address payable, string memory, string memory, uint, uint, uint, CAMPAIGN_STATE ) {
            
        require(_index < numOfCampaigns);
        
        Campaign memory campaign = mapCampaigns[_index];
        
        return (campaign.campaignOwner, campaign.campaignName, campaign.campaignURI, campaign.dueDate, campaign.campaignGoal, 
            campaign.collectedFunds, campaign.campaignStatus);

    }
    
    function getDonorsForCampaign(uint _index) public view returns (address[] memory, uint[] memory) {
        
        require(_index < numOfCampaigns);
        
        Donor[] memory donorsArray = mapDonors[_index];

        address[] memory donorAddresses = new address[](donorsArray.length);
        uint[] memory donorAmount = new uint[](donorsArray.length);
        
        for (uint i; i < donorsArray.length; i++) {
            donorAddresses[i] = donorsArray[i].donorAddress;
            donorAmount[i] = donorsArray[i].donorAmount;
        }
        
        return (donorAddresses, donorAmount);
        
    }
    
    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    // ---------------------------------------------------------------------------------------------    
    // Functions to interact with campaigns 
    // ---------------------------------------------------------------------------------------------    
    
    function createCampaignContract(string memory _name, string memory _url, uint _due, uint _goal) public {
        
        Campaign memory campaign = Campaign({
            campaignOwner:msg.sender,
            campaignName:_name,
            campaignURI:_url,
            dueDate:(now + (_due * 1 days)),
            campaignGoal:_goal,
            collectedFunds:0,
            campaignStatus:CAMPAIGN_STATE.APPROVAL,
            numOfDonors:0
        });
        
        mapCampaigns[numOfCampaigns] = campaign;
        
        numOfCampaigns++;
    }
    
    function approveCampaign(uint _index, bool _approve) public onlyAdmins {
        
        require(_index < numOfCampaigns);
        
        Campaign storage campaign = mapCampaigns[_index];
        
        if (_approve) {
            campaign.campaignStatus = CAMPAIGN_STATE.OPEN ;
        } else {
            campaign.campaignStatus = CAMPAIGN_STATE.REJECTED ;
        }
    }
    
    // ---------------------------------------------------------------------------------------------    
    // Functions to donate funds to campaigns  
    // ---------------------------------------------------------------------------------------------    

    function donate (uint _index, uint _amount) public payable {
        
        require(_index < numOfCampaigns);
        
        uint adminFees = _amount / 10;

        // Update the donors array for the campaign 
        Donor[] storage donorsArray = mapDonors[_index];
        donorsArray.push( Donor ( msg.sender,  ( _amount ) ));
        
        // Update the collected funds in the campaign                
        Campaign storage campaign = mapCampaigns[_index];
        campaign.collectedFunds += _amount - adminFees;
        campaign.numOfDonors ++ ;
        
        // transfer the funds to the admin and the campaign funds wallets
        
        // 90% of the funds will be transferred to the campaignFunds variable 
        // 10% of the funds will be transferred to the donorFunds address 
        transfer(admins[0], adminFees );
        transfer(donorFunds, _amount - adminFees );
        
    }
    
    function closeCampaign(uint _index) public payable onlyAdmins {
        
        Campaign storage campaign = mapCampaigns[_index];
        
        require (campaign.dueDate <= now || campaign.collectedFunds >= campaign.campaignGoal);
        
        // Transfer the funds to campaignOwner - Transferring GIV for now. 
        // @TODO: Convert GIV to USD/ETH by calling UniSwap
        
        transferFrom(donorFunds, campaign.campaignOwner, campaign.collectedFunds);
        
        // Update the campaign status 
        campaign.campaignStatus = CAMPAIGN_STATE.CLOSED;
        
        
    }
    
}

