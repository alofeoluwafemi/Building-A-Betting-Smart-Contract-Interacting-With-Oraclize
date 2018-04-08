
![Smart contract architecture](https://s3.amazonaws.com/alofe.oluwafemi/Oracle-Tutorial.png)
#### What Will I Learn?
In this tutorial you would learn how to build a bet smart contract in solidity that  uses oraclize to get game winner and distribute payout based on result.

- Build a betting smart contract in solidity
- Use Oraclize with ethereum bridge on testnet to  allow your smart contract communicate with third party
- Test for your smart contract using truffle 

#### Requirements
For this tutorial, you will be needing the following.

- A linux machine
- Have node and npm installed on your machine
- Install [truffle](http://truffleframework.com/docs/getting_started/installation) (To complile and test our smart contract)
- Download and install GUI version of [ganache](http://truffleframework.com/ganache/) (To run our own private blockchain)
- Install [ethereum bridge](https://github.com/oraclize/ethereum-bridge) (Allows us to use oraclize on testnet)
- Any IDE that supports solidity syntax, atom or phpstorm will do just fine

#### Difficulty
Intermediate

### Setup
##### Installation
For this tutorial we need to set up a new truffle project for our smart contract. 
- Create a project directory with a suitable name for this tutorial, i would be going with the project name `Game`
- Navigate to the directory in your terminal and run command `truffle init` . Now you would have a project structure that looks exactly like the diagram below.  ![Game](https://s3.amazonaws.com/alofe.oluwafemi/Game.png) The `/var/www/html/Game` was placed there by phpstorm showing the path to my project directory, so if yours does not show that its ok.
- In the contract folder create and name it  **SafeMath.sol** and copy the content from [here](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol) into it. THis is the SafeMath Library by OpenZappelin, we will be needing it.
- In the contract folder create another file with name **OraclizeAPI.sol** also copy the content from [here](#) into it.
##### Buidling A Simple API Endpoint
We would be needing a simple API for oraclize to communicate it to determine the winner of the bet for our smart contract. Just clone [this](#) folder and host it on your server. If you cannot host this on any server you can simply ignore this step and use the url to the one i have hosted on my server.

#### Coding Our Smart Contract
The full code to this project can be found [here](https://github.com/slim12kg/Building-A-Betting-Smart-Contract-Interacting-With-Oraclize).


#### Testing Our Smart Contract




