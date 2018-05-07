pragma solidity ^0.4.19;

import "./Crowdsale.sol";

contract MockCrowdsale is Crowdsale {

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function MockCrowdsale (
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfFakeToken,
        address rewardTokenAddress
    ) Crowdsale(
        ifSuccessfulSendTo, 
        fundingGoalInEthers, 
        durationInMinutes, 
        etherCostOfFakeToken, 
        rewardTokenAddress) public {}

    function flyToDeadline(uint mins) public {
        deadline -= (mins * 1 minutes);
    }
}

