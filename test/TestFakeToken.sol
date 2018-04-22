pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/token/FakeToken.sol";

contract TestFakeToken {
    FakeToken fakeToken = FakeToken(DeployedAddresses.FakeToken());

    // Testing changeOwner() function
    function testChangeOwner() public {
        address to = 0x0000000000000000000000000000000000000001;
        fakeToken.changeOwner(to);
        address newOwner = fakeToken.getOwnerAccount();

        Assert.equal(newOwner, to, "Could not change owner of the contract!");
    }
}