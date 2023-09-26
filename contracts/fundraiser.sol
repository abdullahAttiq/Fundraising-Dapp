// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import the ERC20 interface for USDT (Tether)
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Fundraiser {
    

    struct Campaign {
        uint id;
        address creator;
        uint256 balance;
        bool canceled;
        address[] funders; 
        mapping(address => uint256) contributions;
    }
    
    event fundraiserCreated(uint256 id);
    event fundraiserTerminated(uint256 id);
    event ContributionReceived(uint256 id, address funder, uint256 amount);

 
    mapping(uint256 => Campaign) public allCampaigns;
    uint256 public fundraiserCount;
    address public usdtToken;

    constructor(address _usdtToken) {
        usdtToken = _usdtToken;
    }

   
    function createFundraiser() external {

       fundraiserCount++;

        Campaign storage newCampaign = allCampaigns[fundraiserCount];
        newCampaign.id = fundraiserCount;
        newCampaign.creator = msg.sender;
        newCampaign.balance = 0;
        newCampaign.canceled = false;

        emit fundraiserCreated(fundraiserCount); 

    }



    function contribute(uint256 _fundraiserId, uint256 _amount) external payable {
        validId(_fundraiserId);
        vaildAmount(_amount);
        campaignStatus(_fundraiserId);
        getAllowance(usdtToken,_amount);

        
        IERC20(usdtToken).transferFrom(msg.sender, address(this), _amount);
        Campaign storage campaign = allCampaigns[_fundraiserId];

        campaign.balance += _amount;
        campaign.contributions[msg.sender] += _amount;

    }

    // Cancel a fundraiser by the creator
    function terminateFundraiser(uint256 _fundraiserId) external {
        validId(_fundraiserId);
        onlyCreator(_fundraiserId);

        Campaign storage campaign = allCampaigns[_fundraiserId];
        campaign.canceled = true;

        emit fundraiserTerminated(_fundraiserId);
    }


    function withdrawFunds(uint256 _fundraiserId) external  {
        validId(_fundraiserId);
        campaignStatus(_fundraiserId);
        onlyCreator(_fundraiserId);
        
        Campaign storage campaign = allCampaigns[_fundraiserId];
        
        require(campaign.canceled==true, "Campaign is not finished yet");
        require(campaign.balance > 0, "no funds ");

        // Transfer the funds to the creator
        IERC20(usdtToken).transfer(msg.sender, campaign.balance);
        campaign.balance = 0;
    }


    function getAllowance(
        address  _address,
        uint256 _amount
    ) internal view {
            require(
                IERC20(_address).allowance(
                    msg.sender,
                    address(this)
                ) >= _amount,
                "Insufficient allowance"
            );
        
    }

     function vaildAmount(
        uint256 _amount
    ) internal view {
            require(
                _amount > 0 , "invalid amount passed"

            );
        
    }

    function validId(uint256 _id) internal view {
        require(_id <= fundraiserCount && _id > 0, "Invalid fundraiser ID");
    }
    

    function campaignStatus(uint256 _id) internal view{
        
        require(!allCampaigns[_id].canceled, "Fundraiser is canceled");

    }



    function onlyCreator(uint256 _id) internal view{
        Campaign storage campaign = allCampaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
    } 

    

}
