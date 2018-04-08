pragma solidity ^0.4.21;

import "./BasicToken.sol";

contract FakeToken is BasicToken {

    string public name;    
    string public symbol;      
    uint8 public decimals;

    function FakeToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;       // Give the creator all initial tokens
        totalTokenSupply = _initialAmount;           // Update total supply
        name = _tokenName;                           // Set the name for display purposes
        decimals = _decimalUnits;                    // Amount of decimals for display purposes
        symbol = _tokenSymbol;                       // Set the symbol for display purposes
    }

    /// @notice Reject any ether sent to this contract address
    function () external {
        revert();
    }
}