pragma solidity ^0.4.19;

import "./BasicToken.sol";

contract FakeToken is BasicToken {
    string public name;    
    string public symbol;      
    uint8 public decimals;
    address public ownerAccount;

    event OwnerChanged(address oldOwner, address newOwner);

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

    function getOwnerAccount() public returns (address owner) {
        return ownerAccount;
    }

    /**
     * Changes this contract's owner which holds the initial amount of token
     */
    function changeOwner(address newOwner) public {
        require(ownerAccount == msg.sender);
        transfer(newOwner, balances[ownerAccount]);
        ownerAccount = newOwner;

        OwnerChanged(msg.sender, newOwner);
    }
}