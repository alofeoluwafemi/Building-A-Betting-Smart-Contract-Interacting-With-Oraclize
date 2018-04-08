const Contract = artifacts.require("./Game.sol");

let moment = require("moment");

contract('Place Bet : ', async (accounts) => {

    //Current timestamp
    let now = moment().utc();

    //Set start 10min from now & end time 1hr 40min from now
    //considering a game is 90min
    let start = now.add({minutes : 10}).unix();
    let end = now.add({minutes: 100}).unix();

    it('successfully transfer payout of to winners', async () => {
        let game = await Contract.new(start,end);

        // let event = game.newOraclizeQuery();
        //
        // event.watch(function (error,log) {
        //     if(!error)
        //         console.log(log);
        // });

        //Place bets
        await game.placeBet('swansea',{value: web3.toWei(0.1, "ether"), from: accounts[1]});
        await game.placeBet('swansea',{value: web3.toWei(0.2, "ether"), from: accounts[2]});
        await game.placeBet('realmadrid',{value: web3.toWei(0.3, "ether"), from: accounts[3]});
        await game.placeBet('realmadrid',{value: web3.toWei(0.4, "ether"), from: accounts[4]});

        let prevAccBalance = await web3.eth.accounts[2].balance;

        //End game
        await game.endGame();

        //Retrieve winner from oracle
        await game.getWinner({value: web3.toWei(0.4, "ether")});

        // Wait for the callback to be invoked by oraclize and the event to be emitted
        const logWhenBetClosed = promisifyLogWatch(game.BetClosed({ fromBlock: 'latest' }));

        let log = await logWhenBetClosed;

        assert.equal(log.event, 'BetClosed', 'BetClosed not emitted');

        // await logWhenBetClosed;
        // await game.distributeStake();

        // let totalPayable = await game.totalPayable();
        // let accountPayable = await game.payouts(accounts[2]) / 10 ** 18;

        // let newBalance = await game.getBalance(accounts[2]);

        //Check for total payout to swansea punters
        // assert.equal(0.7, totalPayable / 10 ** 18);

        // accountPayable = web3.fromWei(accountPayable.toNumber(),'ether');
        // prevoiusBalance = web3.fromWei(prevoiusBalance.toNumber(),'ether');
        // newBalance = web3.fromWei(newBalance.toNumber(),'ether');

        // console.log(accountPayable.toString(),prevoiusBalance.toString(),newBalance.toString());
        // console.log(expected.toString(),accountPayable.toString());
    }).timeout(0);

    /**
     * @credit https://github.com/AdamJLemmon
     * Helper to wait for log emission.
     * @param  {Object} _event The event to wait for.
     */
    function promisifyLogWatch(_event) {
        return new Promise((resolve, reject) => {
            _event.watch((error, log) => {
                _event.stopWatching();
                if (error !== null)
                    reject(error);

                resolve(log);
            });
        });
    }
});
