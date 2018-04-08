const Contract = artifacts.require('./Game.sol');

let moment = require("moment");

contract('Check For Winner : ', async (accounts) => {

    //Current timestamp
    let now = moment().utc();

    //Set start 10min from now & end time 1hr 40min from now
    //considering a game is 90min
    let start = now.add({minutes : 10}).unix();
    let end = now.add({minutes: 100}).unix();

    it('game has no winner', async () => {
        let game = await Contract.new(start,end);
        let winner = await game.winner();

        assert.equal(winner,"");
    });

    it('game has as a winner', async () => {
        let game = await Contract.new(start,end);

        await game.endGame();

        await game.getWinner({value: web3.toWei(0.1, "ether")});

        // Wait for the callback to be invoked by oraclize and the event to be emitted
        const logWhenBetClosed = promisifyLogWatch(game.BetClosed({ fromBlock: 'latest' }));

        let log = await logWhenBetClosed;

        assert.equal(log.event, 'BetClosed', 'BetClosed not emitted');
        assert.equal(log.args.result, 'swansea');
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
