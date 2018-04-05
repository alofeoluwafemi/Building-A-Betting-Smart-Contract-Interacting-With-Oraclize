const Contract = artifacts.require("./Game.sol");

let moment = require("moment");

contract('Place Bet : ', async (accounts) => {

  //Current timestamp
  let now = moment().utc();

  //Set start 10mins from now & end time 1hr 40mins from now
  //considering a game is 90mins
  // let start = now.add({minutes : 10}).unix();
  // let end = now.add({minutes: 100}).unix();
  //
  // it('a user can only place bet only if game is not started', async () => {
  //   let game = await Contract.new(start,end);
  //   let status = await game.started();
  //
  //   assert.isFalse(status);
  // })
  //
  // it('two users can stake between 0.01 and 1 ether on any game ones', async () => {
  //   let game = await Contract.new(start,end);
  //   await game.placeBet('realmadrid',{value: web3.toWei(0.01, "ether"), from: accounts[1]});
  //
  //   let betInfoA = await game.getAccountInfo(accounts[1]);
  //
  //   assert.equal(betInfoA[0], accounts[1]);
  //   assert.equal(betInfoA[1], web3.toWei(0.01, "ether"));
  //
  //   await game.placeBet('swansea',{value: web3.toWei(0.1, "ether"), from: accounts[2]});
  //
  //   let betInfoB = await game.getAccountInfo(accounts[2]);
  //
  //   assert.equal(betInfoB[0], accounts[2]);
  //   assert.equal(betInfoB[1], web3.toWei(0.1, "ether"));
  // })
});
