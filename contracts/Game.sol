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

 //Total amount to be distributed among winners
 uint public totalPayable;

 //Total amount of winners stake, to us to calculate
 //ratio of total payable to be payed per account
 uint public totalHolding;

 string public winner;

 //Precision to use for calculation that will yield
 //decimal values to convert to non decimal value
 uint precision = 10 ** 18;

 //Profile of each account betting
 struct Punter {
  address account;
  uint stake;
  string supporting;
 }

 //Lists of all bets placed
 Punter[] public bettings;

 struct Ration {
  address account;
  uint percentage;
 }

 Ration[] public rations;

 mapping (address => uint) public payouts;

 mapping (address => uint) public  payoutAddresses;

 mapping (address => uint) public  bettingAddresses;

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
 * @param start startTime
 * @param end endTime
 */
 function Game(uint start, uint end) public payable {
  startTime = start;
  endTime = end;
  owner = msg.sender;

  OAR = OraclizeAddrResolverI(0xF08dF3eFDD854FEDE77Ed3b2E515090EEe765154);
 }

 /*
 * @returns bool
 */
 function started() public view returns (bool) {
  return block.timestamp >= startTime;
 }

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

 function endGame() onlyOwner public {
  closed = true;
 }

 /*
 * @param address
 * @return team
 * @return stake
 */
 function getAccountInfo(address account) public view returns (address, uint, string) {
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
  }
 }

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
  }
 }

 function calculateTotalPayable() internal {
  require(bettings.length > 0);

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

    payoutAddresses[profile.account] = rations.length - 1;

   }else{
    totalPayable += profile.stake;
   }
  }
 }

 //Calculate each individual payout in percentage
 //ratio of the total payout
 function calculateIndividualRation() internal {
  for(uint i = 0; i < rations.length; ++i) {

   Ration storage ration = rations[i];

   ration.percentage = getPercentage(ration.percentage);
  }
 }

 //Calculate percentage and add precision to eliminate decimals
 //which cannot be handled
 function getPercentage(uint stake) internal view returns (uint) {
  uint percentage = (stake.mul(precision) / totalHolding).mul(100);

  return percentage;
 }

 function getAccountPercentage(address account) public view returns (uint percentage) {
  uint location = payoutAddresses[account];

  return rations[location].percentage;
 }

 function getBalance(address account) public view returns (uint balance) {
  return (address(account).balance);
 }
}