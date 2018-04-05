const Contract = artifacts.require("./Game.sol");

let moment = require("moment");

contract('Check For Winner : ', async (accounts) => {

  //Current timestamp
  let now = moment().utc();

  //Set start 10mins from now & end time 1hr 40mins from now
  //considering a game is 90mins
  let start = now.add({minutes : 10}).unix();
  let end = now.add({minutes: 100}).unix();
  //
  // it('game has no winner', async (event) => {
  //   let game = await Contract.new(start,end);
  //   let winner = await game.winner();
  //
  //   assert.equal(winner,"");
  //   console.log(event);
  // });

  it('game has a winner', async () => {
    let game = await Contract.new(start,end);
    await game.update({value: web3.toWei(0.1, "ether")});

    // --------------------------------------------------------


    var event = game.newOraclizeQuery();

    // watch for changes
    event.watch(function(error, result){
      if (!error)
      console.log(result);
    });

    var eventb = game.BetClosed();

    // watch for changes
    eventb.watch(function(error, result){
      if (!error)
      console.log(result);
    });


    // -----------------------------------------------------------

    setTimeout(async () => {
      let winner = await game.winner();
      let fetch = await game.didfetch();

      console.log("our winner is", winner);
      console.log("did it fetch", fetch);

    }, 35000);
  });
});
