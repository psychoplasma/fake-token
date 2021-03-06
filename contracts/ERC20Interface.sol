pragma solidity ^0.4.21;

/* 
 * @dev EIP20 Token Specification
 * @see https://github.com/psychoplasma/EIPs/blob/master/EIPS/eip-20.md
 */
contract ERC20Interface {
    
    /// @return The total token supply
    function totalSupply() public view returns (uint256 totalTokenSupply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    // solhint-disable-next-line no-simple-event-func-name  
    /// @notice MUST trigger when tokens are transferred, including zero value transfers.
    /// A token contract which creates new tokens SHOULD trigger a Transfer event 
    /// with the _from address set to 0x0 when tokens are created
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    /// @notice MUST trigger on any successful call to approve(address _spender, uint256 _value)
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}