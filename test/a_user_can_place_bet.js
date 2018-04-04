const Contract = artifacts.require("./Game.sol");

let moment = require("moment");

contract('Place Bet : ', async (accounts) => {

  //Current timestamp
  let now = moment().utc();

  //Set start 10mins from now & end time 1hr 40mins from now
  //considering a game is 90mins
  let start = now.add({minutes : 10}).unix();
  let end = now.add({minutes: 100}).unix();

  it('a user can only place bet only if game is not started', async () => {
    let game = await Contract.new(start,end);
    let status = await game.started();

    assert.isFalse(status);
  })

  it('a user stake 0.01 ether', async () => {
    let game = await Contract.new(start,end);
    let results = await game.placeBet('realmadrid',{value: web3.toWei(0.01, "ether"), from: accounts[1]});
    let betInfo = await game.getAccountInfo(accounts[1]);

    console.log(betInfo);
  })
});
