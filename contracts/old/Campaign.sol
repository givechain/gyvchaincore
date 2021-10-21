// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

contract Campaign {
    
    address payable[] admins ;
    address payable public campaignOwner ;
    string public campaignName ;
    string public campaignURI ;
    uint public dueDate ;
    uint public campaignGoal ;
    uint public collectedFunds ;
    address campaignFactoryContract;
    
    struct donor {
        address payable donorAddress ;
        uint donatedAmount ;
    }
    
    donor[] public donorsArray ;
    
    enum CAMPAIGN_STATE {
        APPROVAL,
        REJECTED,
        OPEN,
        CLOSED
    }
    
    CAMPAIGN_STATE public campaignStatus;
    
    modifier onlyCampaignFactory() {
        require(msg.sender == campaignFactoryContract, "This function can only be called from the factory contract");
        _;
    }
    
    constructor(address payable _owner, string memory _name, string memory _url, uint _due, uint _goal ) public {
        admins.push(0x4331FB28b46E926787641003D8888625d854b6D6);
        
        campaignFactoryContract = msg.sender;
        campaignOwner = _owner ;
        
        campaignName = _name ; 
        campaignURI = _url ; 
        dueDate = now + (_due * 1 days);
        campaignGoal = _goal;
        
        campaignStatus = CAMPAIGN_STATE.APPROVAL ;
        
    }

    function getDetails() public view 
        returns (address payable, string memory, CAMPAIGN_STATE, string memory, uint, uint, uint) {
            return (campaignOwner, campaignName, campaignStatus, campaignURI, dueDate, campaignGoal, collectedFunds);
        }
    
    function approveCampaign(bool _approve) public onlyCampaignFactory {
        if (_approve) {
            campaignStatus = CAMPAIGN_STATE.OPEN ;
        } else {
            campaignStatus = CAMPAIGN_STATE.REJECTED ;
        }
    }
    
    function donate( address payable _donorAddress, uint _amount) public {
        
        require(campaignStatus == CAMPAIGN_STATE.OPEN, "Not possible to donate to this campaign right now");
        
        // Check if this address is there in the donors list 
        bool existingDonor;
        for (uint i = 0; i < donorsArray.length; i++) {
            if (donorsArray[i].donorAddress == _donorAddress) {
                
                // Update amount value in the array 
                donorsArray[i].donatedAmount += _amount;
                
                existingDonor = true;
                break;
            }
            
        }
        
        if (!existingDonor) {
            donorsArray.push( donor(_donorAddress, _amount));
        }
        
        collectedFunds += _amount;
        
    }
    
    // function payOutDonors()
    
    function getDonors() public view returns (address payable[] memory , uint[] memory) {
        
        address payable[] memory donorAddresses = new address payable[](donorsArray.length);
        uint[] memory donorAmount = new uint[](donorsArray.length);
        
        for (uint i; i < donorsArray.length; i++) {
            donorAddresses[i] = donorsArray[i].donorAddress;
            donorAmount[i] = donorsArray[i].donatedAmount;
        }
    
        return (donorAddresses, donorAmount);
    }
    
    
    function withdrawCampaign() public onlyCampaignFactory {
        require (campaignStatus == CAMPAIGN_STATE.OPEN || campaignStatus == CAMPAIGN_STATE.APPROVAL,"Campaign cant be withdrawn at this stage");
        
        
        uint toCampaignOwner = collectedFunds * 9 / 10;
        
        campaignOwner.transfer(toCampaignOwner);
        
        uint toEachAdmin = (collectedFunds - toCampaignOwner ) / admins.length;
        
        for (uint i; i < admins.length; i++) {
            admins[i].transfer(toEachAdmin);
        }
        
        campaignStatus = CAMPAIGN_STATE.CLOSED;
    }
     
        
    
    
}