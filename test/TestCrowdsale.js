const ether = require('./ether');

const BigNumber = web3.BigNumber;

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const Crowdsale = artifacts.require('MockCrowdsale');
const FakeToken = artifacts.require('FakeToken');

contract('Crowdsale', () => {
  const rate = 1000;
  const value = new BigNumber(50);
  const tokenSupply = new BigNumber('1e7');
  const expectedTokenAmount = value.mul(rate);
  const durationInMin = new BigNumber(60);
  const crowdsaleBeneficiary = web3.eth.accounts[1];

  beforeEach(async () => {
    this.token = await FakeToken.new(tokenSupply, 'Fake Token', 7, 'FTK');
    this.crowdsale = await Crowdsale.new(crowdsaleBeneficiary, value, durationInMin, rate, this.token.address);
    await this.token.transfer(this.crowdsale.address, tokenSupply);
  });

  // TODO: Move this to TestFakeToken
  describe('fake token rejects ether', () => {
    it('should reject ether', async () => {
      await this.token.sendTransaction({value: web3.toWei(1, 'ether')}).should.be.rejected;
    });
  });

  describe('has enough supply', () => {
    it('should have enough supply', async () => {
      let crowdsaleToken = await this.token.balanceOf(this.crowdsale.address);
      crowdsaleToken.should.be.bignumber.equal(tokenSupply);
      tokenSupply.should.be.bignumber.above(expectedTokenAmount);
    });
  });

  describe('accepting funds', () => {
    let funder = web3.eth.accounts[2];
    let funding = new BigNumber(2);

    it('should accept funds', async () => {
      // Fund the crowdsale contract
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.fulfilled;
      // Get the funder's token balance
      let funderTokens = await this.token.balanceOf(funder);
      // Calculate the expected token balance
      let expectedFunderTokens = funding.mul(rate);
      // Check if expected and real token balances are equal
      funderTokens.should.be.bignumber.equal(expectedFunderTokens);
    });

    it('should have balance equals to total funding', async () => {
      let pre = web3.eth.getBalance(this.crowdsale.address);
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder});
      let post = web3.eth.getBalance(this.crowdsale.address);
      post.sub(pre).should.be.bignumber.equal(ether(funding));
    });
  });

  describe('deadline has been reached', () => {
    let funder = web3.eth.accounts[2];
    let funding = new BigNumber(2);

    it('should reject further payments', async () => {
      await this.crowdsale.flyToDeadline(durationInMin + 1);
      await this.crowdsale.checkGoalReached().should.be.fulfilled;
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.rejected;
    });
  });

  describe('goal has been reached', () => {
    let funder = web3.eth.accounts[2];
    let funding = value.add(1);

    it('should raised amount be equal to total funding', async () => {
      // Fund the contract more than the goal of the crowd sale
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.fulfilled; 
      // Fly away to the deadline
      await this.crowdsale.flyToDeadline(durationInMin + 1);
      // Check whether the goal is reached or not
      let {logs} = await this.crowdsale.checkGoalReached().should.be.fulfilled;
      // Check whether "GoalReached" event has been emitted or not
      let event = logs.find(e => e.event === 'GoalReached');
      should.exist(event);
      // Check whether the sent funding is equal to the raised amount
      event.args.totalAmountRaised.should.be.bignumber.equal(ether(funding));
    });
  });

  describe('successful crowdsale', () => {
    let funder = web3.eth.accounts[5];
    let funding = value.add(1);

    it('should transfer the raised amount to the beneficiary', async () => {
      // Fund the contract more than the goal of the crowd sale
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.fulfilled; 
      // Fly away to the deadline
      await this.crowdsale.flyToDeadline(durationInMin + 1);
      // Check whether the goal is reached or not
      let logObj = await this.crowdsale.checkGoalReached().should.be.fulfilled;
      // Check whether "GoalReached" event has been emitted or not
      let event = logObj.logs.find(e => e.event === 'GoalReached');
      should.exist(event);

      let beneficiaryBalancePre = web3.eth.getBalance(crowdsaleBeneficiary);
      // Withdraw the raised amount from the crowdsale contract to beneficiary's account
      logObj = await this.crowdsale.safeWithdrawal({from: crowdsaleBeneficiary}).should.be.fulfilled; 
      // Check whether "FundTransfer" event has been emitted or not
      event = logObj.logs.find(e => e.event === 'FundTransfer');
      should.exist(event);
      // Get beneficiary account's ether balance
      let beneficiaryBalancePost = web3.eth.getBalance(crowdsaleBeneficiary);
      // Check whether the raised amount and the ether sent back to beneficiary's account is equal
      // TODO: find a better way to add up the gas amount spent back to beneficiary's account
      beneficiaryBalancePost.sub(beneficiaryBalancePre).should.be.bignumber.above(ether(value));
    });
  });

  describe('unsuccessful crowdsale', () => {
    let funder = web3.eth.accounts[6];
    let funding = value.sub(1);

    it('should not transfer the raised amount to the beneficiary', async () => {
      // Fund the contract more than the goal of the crowd sale
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.fulfilled; 
      // Fly away to the deadline
      await this.crowdsale.flyToDeadline(durationInMin + 1);
      // Check whether the goal is reached or not
      let logObj = await this.crowdsale.checkGoalReached().should.be.fulfilled;
      // Check whether "GoalReached" event has been emitted or not
      let event = logObj.logs.find(e => e.event === 'GoalReached');
      should.not.exist(event);

      let beneficiaryBalancePre = web3.eth.getBalance(crowdsaleBeneficiary);
      // Withdraw the raised amount from the crowdsale contract to beneficiary's account
      logObj = await this.crowdsale.safeWithdrawal({from: crowdsaleBeneficiary}).should.be.fulfilled; 
      // Check whether "FundTransfer" event has been emitted or not
      event = logObj.logs.find(e => e.event === 'FundTransfer');
      should.not.exist(event);
      // Get beneficiary account's ether balance
      let beneficiaryBalancePost = web3.eth.getBalance(crowdsaleBeneficiary);
      // Check whether the raised amount and the ether sent back to beneficiary's account is equal
      // TODO: find a better way to add up the gas amount spent back to beneficiary's account
      beneficiaryBalancePost.sub(beneficiaryBalancePre).should.be.bignumber.below(ether(1));
    });

    it('should transfer the funds to the funders back', async () => {
      // Fund the contract more than the goal of the crowd sale
      await this.crowdsale.sendTransaction({value: ether(funding), from: funder}).should.be.fulfilled; 
      // Fly away to the deadline
      await this.crowdsale.flyToDeadline(durationInMin + 1);
      // Check whether the goal is reached or not
      let logObj = await this.crowdsale.checkGoalReached().should.be.fulfilled;
      // Check whether "GoalReached" event has been emitted or not
      let event = logObj.logs.find(e => e.event === 'GoalReached');
      should.not.exist(event);

      let beneficiaryBalancePre = web3.eth.getBalance(funder);
      // Withdraw the raised amount from the crowdsale contract to beneficiary's account
      logObj = await this.crowdsale.safeWithdrawal({from: funder}).should.be.fulfilled; 
      // Check whether "FundTransfer" event has been emitted or not
      event = logObj.logs.find(e => e.event === 'FundTransfer');
      should.exist(event);
      event.args.amount.should.be.bignumber.equal(ether(funding));
      // Get beneficiary account's ether balance
      let beneficiaryBalancePost = web3.eth.getBalance(funder);
      // Check whether the raised amount and the ether sent back to beneficiary's account is equal
      // TODO: find a better way to add up the gas amount spent back to beneficiary's account
      beneficiaryBalancePost.sub(beneficiaryBalancePre).should.be.bignumber.below(ether(funding));
      beneficiaryBalancePost.sub(beneficiaryBalancePre).should.be.bignumber.above(ether(funding.sub(1)));
    });
  });
});
