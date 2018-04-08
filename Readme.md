
![Smart contract architecture](https://s3.amazonaws.com/alofe.oluwafemi/Oracle-Tutorial.png)

#### Overview
The smart contract takes bet on a game between two teams, and at the end of the game checks for the winning team using oraclizeAPI then distributes loosers pool to winners based on percentage ratio of individual bet.

`Pretty smart hun!`


----------


#### What Will I Learn?
In this tutorial you would learn how to build a smart contract in solidity that uses oraclize to get information form a third party.

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
We would be needing a simple API for oraclize to communicate it to determine the winner of the bet for our smart contract. 
`You can skip this step and simply use the existing endpoint`

Create a a subdomain `api` on your server so we can have something like `https://www.api.yourdomain.com`. In the folder pointing to your subdomain create a file `index.php` and put the content below.

```php
<?php  
  
$game = file_get_contents(__DIR__.DIRECTORY_SEPARATOR.'game.json');  
  
header("Content-Type: application/json;charset=utf-8");  
  
print_r($game);  
  
exit;
```
Create another file `game.json` and also put the content below.

```php
{  
  "winner": "swansea"  
}
```

Now if you visit your subdomain url your page should return a valid json file. When oraclize calls the url its should be able to get the winner.

#### Coding Our Smart Contract
The full code to this project can be found [here](https://github.com/slim12kg/Building-A-Betting-Smart-Contract-Interacting-With-Oraclize).
##### The Code
```js
pragma solidity ^0.4.18;  
  
import "./OraclizeAPI.sol";  
  
import "./SafeMath.sol";  
  
contract Game is usingOraclize {  
  
  using SafeMath for uint;  
  
  //MINIMUM_STAKE allowed is 0.01 ether  
  uint public constant MINIMUM_STAKE = 10 ** 16;  
  
  //MAXIMUM_STAKE allowed is 1 ether  
  uint public constant MAXIMUM_STAKE = 10 ** 18;  
  
  string public constant TEAM_A = 'realmadrid';  
  
  string public constant TEAM_B = 'swansea';  
  
  //Game playoff  
  uint256 public startTime;  
  
  //Game off  
  uint256 public endTime;  
  
  //Address that created the contract  
  address public owner;  
  
  //Address that bet charges are paid to  
  address public referee;  
  
  bool public closed = false;  
  
  uint public totalPayable;  
  
  uint public totalHolding;  
  
  string public winner;  
  
  uint precision = 10 ** 18;  
  
  struct Punter {  
  address account;  
  uint stake;  
  string supporting;  
 }  
 
  Punter[] public bettings;  
  
  struct Ration {  
  address account;  
  uint percentage;  
 }  
 
  Ration[] public rations;  
  
  mapping (address => uint) public payouts;  
  
  mapping (address => uint) public payoutAddresses;  
  
  mapping (address => uint) public bettingAddresses;  
  
  mapping (bytes32 => bool) public queryIds;  
  
  modifier onlyOwner() {  
  require(msg.sender == owner);  
  
  _;  
 }  
 
  modifier ended() {  
  require(block.timestamp >= endTime || closed == true);  
  
  _;  
 }  
 
  modifier notStarted() {  
  require(started() == false);  
  
  _;  
 }  
 
  modifier validContribution() {  
  require(msg.value >= MINIMUM_STAKE && msg.value <= MAXIMUM_STAKE);  
  
  _;  
 }  
 
  modifier haveNoStake() {  
  require(bettingAddresses[msg.sender] == 0);  
  
  _;  
 }  
 
  modifier validTeam(string team) {  
  require(keccak256(TEAM_A) == keccak256(team) || keccak256(TEAM_B) == keccak256(team));  
  
  _;  
 }  
 
  modifier notClosed() {  
  require(closed  == false);  
  
  _;  
 }  
 
  event Bet(address account, uint amount);  
  
  event BetClosed(uint timestamp, string result);  
  
  event FetchedResult(string winner);  
  
  event newOraclizeQuery(string description);  
  
  event Payment(uint winning);  
  
  /*  
 * @param start startTime * @param end endTime */  function Game(uint start, uint end) public payable {  
  startTime = start;  
  endTime = end;  
  owner = msg.sender;  
  
  OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);  
 }  
 
  /*  
 * @returns bool */  function started() public view returns (bool) {  
  return block.timestamp >= startTime;  
 }  
  /*  
 * @param team realmadrid, swansea */  function placeBet(string team) notStarted validContribution haveNoStake validTeam(team) public payable returns (uint) {  
  bettings.push(Punter({  
  account: msg.sender,  
   stake: msg.value,  
   supporting: team  
   }));  
  
  bettingAddresses[msg.sender] = bettings.length - 1;  
  
  Bet(msg.sender, msg.value);  
 }  
  function endGame() onlyOwner public {  
  closed = true;  
 }  
 
  /*  
 * @param address * @return team * @return stake */  function getAccountInfo(address account) public view returns (address, uint, string) {  
  uint location = bettingAddresses[account];  
  
  Punter storage info = bettings[location];  
  
  return (info.account,info.stake,info.supporting);  
 }  
 
  function getWinner() ended public payable {  
  if (oraclize_getPrice("URL") > this.balance) {  
  newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");  
 } else {  
  newOraclizeQuery("Oraclize query was sent, standing by for the answer..");  
  bytes32 queryId = oraclize_query("URL", "json(https://www.api.ogunmoye.com).winner");  
  
  queryIds[queryId] = true;  
 } }  
 
  function __callback(bytes32 myid, string result) public {  
  require(msg.sender == oraclize_cbAddress());  
  require(queryIds[myid] == true);  
  
  winner = result;  
  closed = true;  
  
  delete queryIds[myid];  
  
  FetchedResult(result);  
  BetClosed(block.timestamp, result);  
 }  
  function distributeStake() onlyOwner public payable returns (address){  
  calculateTotalPayable();  
  calculateIndividualRation();  
  
  for(uint i = 0; i < rations.length; ++i) {  
  Ration storage ration = rations[i];  
  uint winning = ration.percentage.div(100) * totalPayable;  
  
  winning = winning.div(10 ** 18);  
  
  payouts[ration.account] = winning;  
  
  address(ration.account).transfer(winning);  
  
  Payment(winning);  
 } }  
 
  function calculateTotalPayable() internal {  
  require(bettings.length > 0);  
  
  for(uint i = 0; i < bettings.length; ++i) {  
  
  Punter storage profile = bettings[i];  
  
  //String cannot be compared directly  
 //Hash to do comparision  if(keccak256(profile.supporting) == keccak256(winner)) {  
  totalHolding += profile.stake;  
  
  rations.push(Ration({  
  account: profile.account,  
     percentage: profile.stake  
     }));  
  
  payoutAddresses[profile.account] = rations.length - 1;  
  
 }else{  
  totalPayable += profile.stake;  
 } } }  
  //Calculate each individual payout in percentage  
 //ratio of the total payout  function calculateIndividualRation() internal {  
  for(uint i = 0; i < rations.length; ++i) {  
  
  Ration storage ration = rations[i];  
  
  ration.percentage = getPercentage(ration.percentage);  
 } }  
 
  //Calculate percentage and add precision to eliminate decimals  
 //which cannot be handled  function getPercentage(uint stake) internal view returns (uint) {  
  uint percentage = (stake.mul(precision) / totalHolding).mul(100);  
  
  return percentage;  
 }  
 
  function getAccountPercentage(address account) public view returns (uint percentage) {  
  uint location = payoutAddresses[account];  
  
  return rations[location].ppragma solidity ^0.4.18;  
  
import "./OraclizeAPI.sol";  
  
import "./SafeMath.sol";  
  
contract Game is usingOraclize {  
  
  using SafeMath for uint;  
  
  //MINIMUM_STAKE allowed is 0.01 ether  
  uint public constant MINIMUM_STAKE = 10 ** 16;  
  
  //MAXIMUM_STAKE allowed is 1 ether  
  uint public constant MAXIMUM_STAKE = 10 ** 18;  
  
  string public constant TEAM_A = 'realmadrid';  
  
  string public constant TEAM_B = 'swansea';  
  
  //Game playoff  
  uint256 public startTime;  
  
  //Game off  
  uint256 public endTime;  
  
  //Address that created the contract  
  address public owner;  
  
  //Address that bet charges are paid to  
  address public referee;  
  
  bool public closed = false;  
  
  uint public totalPayable;  
  
  uint public totalHolding;  
  
  string public winner;  
  
  uint precision = 10 ** 18;  
  
  struct Punter {  
  address account;  
  uint stake;  
  string supporting;  
 }  
 
  Punter[] public bettings;  
  
  struct Ration {  
  address account;  
  uint percentage;  
 }  
 
  Ration[] public rations;  
  
  mapping (address => uint) public payouts;  
  
  mapping (address => uint) public payoutAddresses;  
  
  mapping (address => uint) public bettingAddresses;  
  
  mapping (bytes32 => bool) public queryIds;  
  
  modifier onlyOwner() {  
  require(msg.sender == owner);  
  
  _;  
 }  
  modifier ended() {  
  require(block.timestamp >= endTime || closed == true);  
  
  _;  
 }  
  modifier notStarted() {  
  require(started() == false);  
  
  _;  
 }  
  modifier validContribution() {  
  require(msg.value >= MINIMUM_STAKE && msg.value <= MAXIMUM_STAKE);  
  
  _;  
 }  
  modifier haveNoStake() {  
  require(bettingAddresses[msg.sender] == 0);  
  
  _;  
 }  
  modifier validTeam(string team) {  
  require(keccak256(TEAM_A) == keccak256(team) || keccak256(TEAM_B) == keccak256(team));  
  
  _;  
 }  
  modifier notClosed() {  
  require(closed  == false);  
  
  _;  
 }  
  event Bet(address account, uint amount);  
  
  event BetClosed(uint timestamp, string result);  
  
  event FetchedResult(string winner);  
  
  event newOraclizeQuery(string description);  
  
  event Payment(uint winning);  
  
  /*  
 * @param start startTime * @param end endTime */  function Game(uint start, uint end) public payable {  
  startTime = start;  
  endTime = end;  
  owner = msg.sender;  
  
  OAR = OraclizeAddrResolverI(0xF08dF3eFDD854FEDE77Ed3b2E515090EEe765154);  
 }  
  /*  
 * @returns bool */  function started() public view returns (bool) {  
  return block.timestamp >= startTime;  
 }  
  /*  
 * @param team realmadrid, swansea */  function placeBet(string team) notStarted validContribution haveNoStake validTeam(team) public payable returns (uint) {  
  bettings.push(Punter({  
  account: msg.sender,  
   stake: msg.value,  
   supporting: team  
   }));  
  
  bettingAddresses[msg.sender] = bettings.length - 1;  
  
  Bet(msg.sender, msg.value);  
 }  
  function endGame() onlyOwner public {  
  closed = true;  
 }  
  /*  
 * @param address * @return team * @return stake */  function getAccountInfo(address account) public view returns (address, uint, string) {  
  uint location = bettingAddresses[account];  
  
  Punter storage info = bettings[location];  
  
  return (info.account,info.stake,info.supporting);  
 }  
  function getWinner() ended public payable {  
  if (oraclize_getPrice("URL") > this.balance) {  
  newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");  
 } else {  
  newOraclizeQuery("Oraclize query was sent, standing by for the answer..");  
  bytes32 queryId = oraclize_query("URL", "json(https://www.api.ogunmoye.com).winner");  
  
  queryIds[queryId] = true;  
 } }  
  function __callback(bytes32 myid, string result) public {  
  require(msg.sender == oraclize_cbAddress());  
  require(queryIds[myid] == true);  
  
  winner = result;  
  closed = true;  
  
  delete queryIds[myid];  
  
  FetchedResult(result);  
  BetClosed(block.timestamp, result);  
 }  
  function distributeStake() onlyOwner public payable returns (address){  
  calculateTotalPayable();  
  calculateIndividualRation();  
  
  for(uint i = 0; i < rations.length; ++i) {  
  Ration storage ration = rations[i];  
  uint winning = ration.percentage.div(100) * totalPayable;  
  
  winning = winning.div(10 ** 18);  
  
  payouts[ration.account] = winning;  
  
  address(ration.account).transfer(winning);  
  
  Payment(winning);  
 } }  
  function calculateTotalPayable() internal {  
  require(bettings.length > 0);  
  
  for(uint i = 0; i < bettings.length; ++i) {  
  
  Punter storage profile = bettings[i];  
  
  //String cannot be compared directly  
 //Hash to do comparision  if(keccak256(profile.supporting) == keccak256(winner)) {  
  totalHolding += profile.stake;  
  
  rations.push(Ration({  
  account: profile.account,  
     percentage: profile.stake  
     }));  
  
  payoutAddresses[profile.account] = rations.length - 1;  
  
 }else{  
  totalPayable += profile.stake;  
 } } }  
  //Calculate each individual payout in percentage  
 //ratio of the total payout  function calculateIndividualRation() internal {  
  for(uint i = 0; i < rations.length; ++i) {  
  
  Ration storage ration = rations[i];  
  
  ration.percentage = getPercentage(ration.percentage);  
 } }  
  //Calculate percentage and add precision to eliminate decimals  
 //which cannot be handled  function getPercentage(uint stake) internal view returns (uint) {  
  uint percentage = (stake.mul(precision) / totalHolding).mul(100);  
  
  return percentage;  
 }  
 
  function getAccountPercentage(address account) public view returns (uint percentage) {  
  uint location = payoutAddresses[account];  
  
  return rations[location].percentage;  
 }
 
  function getBalance(address account) public view returns (uint balance) {  
  return (address(account).balance);  
 }}ercentage;  
 }  
 
  function getBalance(address account) public view returns (uint balance) {  
  return account.balance;  
 }}
```
######  CODE HIGHLIGHTS

Notice the two import statements:

The fisrt one imports the Oraclize API contract containing methods such as `oraclize_getPrice` ,`oraclize_query`   that we will use to interact with oracle and allows us to implement a `__callback` method that will be called when oraclize returns result after a successfull request. 

And SafeMath Library by [Zeppelin](https://openzeppelin.org/) to perform mathematical calculation, in this code the `using SafeMath for uint` is used to allow the methods of SafeMath library to be called directly on integers

```js
import "./OraclizeAPI.sol";  
  
import "./SafeMath.sol";
```
To use oraclize with on testnet, launch your [installed](http://truffleframework.com/ganache/) ganache GUI then navigate to `ethereum bridge` directory you cloned from [here](https://github.com/oraclize/ethereum-bridge)  and run command `node bridge -H localhost:7545 -a 0 --dev` on your terminal.

You would be presented with a similar screen like below
![OAR](https://s3.amazonaws.com/alofe.oluwafemi/OAR.png)

Copy the where it says `Please add this line to your contract constructor` . Note do not use the one icluded in this snippet as it might not work for you.

```php
/*  
* @param start startTime  
* @param end endTime  
*/  
function Game(uint start, uint end) public payable {  
  startTime = start;  
  endTime = end;  
  owner = msg.sender;  
  
  OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);  
}
```
The constructor initializes with the `startTime` and `endTime` of the game. Next lets take a look at the method to place bet.

```php
/*  
* @param team realmadrid, swansea  
*/  
function placeBet(string team) notStarted validContribution haveNoStake validTeam(team) public payable returns (uint) {  
  bettings.push(Punter({  
  account: msg.sender,  
  stake: msg.value,  
  supporting: team  
  }));  
  
  bettingAddresses[msg.sender] = bettings.length - 1;  
  
  Bet(msg.sender, msg.value);  
}
```
The method takes only one argument which is one of the two teams we have in our contract. It also checks against the  following modifier `notStarted`, `validContribution`, `haveNoStake` `validTeam`

```php
//Checks if team is one of the allowed teams
//TEAM_A = 'realmadrid'
//EAM_B = 'swansea'
modifier validTeam(string team) {  
  require(keccak256(TEAM_A) == keccak256(team) || keccak256(TEAM_B) == keccak256(team));  
  
  _;  
}

//Check if the person placing the bet does not already
//have an existing bet
modifier haveNoStake() {  
  require(bettingAddresses[msg.sender] == 0);  
  
  _;  
}

//Check if ether sent is not less than 0.1 ether
//or greater than 1 ether
modifier validContribution() {  
  require(msg.value >= MINIMUM_STAKE && msg.value <= MAXIMUM_STAKE);  
  
  _;  
}

//Ensure bet will only be allowed only
//before match time
modifier notStarted() {  
  require(started() == false);  
  
  _;  
}
```
Now comes the most interesting part:

Once the game is over you can end the game by calling method `endGame` which can only be called by the owing account used to create this contract.  Once the game is over the contract will allow owner to call the `getWinner` method.

```php
function getWinner() ended public payable {  
  //Check if there is enough balance in contract
  if (oraclize_getPrice("URL") > this.balance) { 
  //If this contract does not have enough balance fire event to notify 
  newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");  
 } else {  
  //Fire event to notify successfull all to endpoint
  newOraclizeQuery("Oraclize query was sent, standing by for the answer..");  
	
  //Save queryId for later validation to ensure same query id was returned with response	
  bytes32 queryId = oraclize_query("URL", "json(https://www.api.ogunmoye.com).winner");  
  
  queryIds[queryId] = true;  
 }}
``` 

Once the request is successfull, Oraclize will return a response to the `__callback` function
in our contract that was implemented from the OraclizeAPI.

```php
function __callback(bytes32 myid, string result) public { 
  //Check if calling address is valid
  require(msg.sender == oraclize_cbAddress());  
  //Validate if query id is the same 
  //we have 
  require(queryIds[myid] == true);  
  
  //Set winner as result
  //and close the betting
  winner = result;  
  closed = true;  
  
  delete queryIds[myid];  
  
  FetchedResult(result);  
  BetClosed(block.timestamp, result);  
}
```
Finally we will look into the `distributeSTake` method, this methods does three things:

First it calculates the total payable to the accounts that bet on the winner team

```php
function calculateTotalPayable() internal {
  //We can only calculate payable if there are more
  //than one bet  
  require(bettings.length > 0);  
  
  //Loop through all the bets
  //Check if an account bet on winning team then
  //add the account stake to totalHolding(Sum of all stake of winners)
  //push the account info into an array of ratios
  //to later calculate the ration of the winning to be payed out to it.
  //Else sum the total of account that lost the bet as totalPayable
  for(uint i = 0; i < bettings.length; ++i) {  
  
  Punter storage profile = bettings[i];  
  
  //String cannot be compared directly  
  //Hash to do comparision  
  if(keccak256(profile.supporting) == keccak256(winner)) {  
  totalHolding += profile.stake;  
  
  rations.push(Ration({  
  account: profile.account,  
    percentage: profile.stake  
    }));  
  
  //Store indexes of where account info are located
  //for easy access using the address as key on a map
  payoutAddresses[profile.account] = rations.length - 1;  
  
 }else{  
  totalPayable += profile.stake;  
 } }}
```

Now that the total amount payable have been calculated and we have stored the information of the winners. The method then calls the `calculateIndividualRation` method to get the percentage of the total payout that should go to each account. using the formulae  `stake/totalHolding * 100`, where `totalHolding` is sum of all stake of the account that bet on the winning team, allowing us to determin what ratio the account contributed to the total pool.

```php
//Calculate each individual payout in percentage  
//ratio of the total payout  
function calculateIndividualRation() internal {  
  for(uint i = 0; i < rations.length; ++i) {  
  
  Ration storage ration = rations[i];  
  
  ration.percentage = getPercentage(ration.percentage);  
 }}  
  
//Calculate percentage and add precision to eliminate decimals  
//which cannot be handled  
function getPercentage(uint stake) internal view returns (uint) {  
  uint percentage = (stake.mul(precision) / totalHolding).mul(100);  
  
  return percentage;  
}
```
**Note:** One thing to note is that since solidity doesn't provide a way to store decimal values, a precision of  <small>10e<sup>17</sup></small>   is used to multiply the percentage value since ether is 18 decimal place this will be sure to eliminate any occurence of decimal point and when payout is to be carried out the precision will be deducted and the value will be transfered in wei.

Now that we have the percentage of actual individual payout, the method then loop through the addresses and multpily the percentage with the total payout and divide it by the precision to determine the actual value in wei and finally make transfer.

```php
for(uint i = 0; i < rations.length; ++i) {  
  Ration storage ration = rations[i];  
  uint winning = ration.percentage.div(100) * totalPayable;  
  
  winning = winning.div(10 ** 18);  
  
  payouts[ration.account] = winning;  
  
  address(ration.account).transfer(winning);  
  
  Payment(winning);  
}
```

#### Testing Our Smart Contract
We would be writing three tests



