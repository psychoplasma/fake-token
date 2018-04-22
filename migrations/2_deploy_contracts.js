var FakeToken = artifacts.require("FakeToken");
var Crowdsale = artifacts.require("Crowdsale");

module.exports = function(deployer) {
  deployer.deploy(FakeToken, 3000000, "Fake Token", 6, "FKT").then(() => {
    deployer.deploy(
      Crowdsale, 
      "0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef",
      3000,
      30,
      1,
      FakeToken.address);
  });
};
