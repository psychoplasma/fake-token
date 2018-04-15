pragma solidity ^0.4.19;

import "./BasicToken.sol";

contract FakeToken is BasicToken {
    string public name;    
    string public symbol;      
    uint8 public decimals;
    address public ownerAccount;

    function FakeToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        ownerAccount = msg.sender;
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

    function getOwnerAccount() external returns (address owner) {
        return ownerAccount;
    }

    function changeOwner(address newOwner) public {
        require(ownerAccount == msg.sender);
        transfer(newOwner, balances[ownerAccount]);
        ownerAccount = newOwner;
    }
}