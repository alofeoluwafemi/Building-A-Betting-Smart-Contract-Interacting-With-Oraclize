pragma solidity ^0.4.18;

import "./OraclizeAPI.sol";

contract Game is usingOraclize {

 //MINIMUM_STAKE allowed is 0.01 ether
 uint public constant MINIMUM_STAKE = 10 ** 16;

 //MAXIMUM_STAKE allowed is 1 ether
 uint public constant MAXIMUM_STAKE = 10 ** 18;

 string public constant TEAM_A = 'realmadrid';

 string public constant TEAM_B = 'swansea';

 //Game kickoff
 uint256 public startTime;

 //Game Signoff
 uint256 public endTime;

 //Address that created the contract
 address public owner;

 //Address that bet charges are paid to
 address public referee;

 bool public closed = false;

 uint public payout;

 string public winner;

 struct Punter {
  address account;
  uint stake;
  string supporting;
 }

 Punter[] public bettings;

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

 event Loser(string loser, string winner, bool status);

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

 function __callback(bytes32 myid, string result, bytes proof) public {
  require(msg.sender == oraclize_cbAddress());
  require(queryIds[myid] == true);

  winner = result;
  closed = true;

  delete queryIds[myid];

  FetchedResult(result);
  BetClosed(block.timestamp, result);
 }

 function setBeneficiaryAddress(address beneficiary) public {
  referee = beneficiary;
 }

 function distributeStake() onlyOwner public payable returns (address){
  calculatePayout();
 }

 function calculatePayout() internal {
  require(bettings.length > 0);

  for(uint i = 0; i < bettings.length; ++i) {

   Punter profile = bettings[i];

   Loser(profile.supporting, winner, keccak256(profile.supporting) == keccak256(winner));

   //String cannot be compared directly
   //Hash to do comparision
   if(keccak256(profile.supporting) == keccak256(winner)) continue;

   payout += profile.stake;

   //Remove addresses that lost bet
   delete bettingAddresses[profile.account];
   delete bettings[i];
  }
 }
}