pragma solidity ^0.4.19;

import "../token/FakeToken.sol";
import "../utils/SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;

    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    FakeToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address funder, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function Crowdsale (
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfFakeToken,
        address rewardTokenAddress
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfFakeToken * 1 ether;
        tokenReward = FakeToken(rewardTokenAddress);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function 
     * that is called whenever anyone sends funds to a contract
     */
    function () external payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        tokenReward.transfer(msg.sender, amount.div(price));
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { 
        require(now >= deadline);
        _;
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, 
     * and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. 
     * If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() public afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
}

