pragma solidity ^0.4.21;

import "./ERC20Interface.sol";
import "./utils/SaferMath.sol";


contract BasicToken is ERC20Interface {
    using SaferMath for uint256;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    uint256 totalTokenSupply;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function totalSupply() public view returns (uint256 tokenSupply) {
        return totalTokenSupply;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0) && balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        /// Check if _from has enough balance and allowance for _value to be transferred 
        require(_to != address(0) && balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }
}