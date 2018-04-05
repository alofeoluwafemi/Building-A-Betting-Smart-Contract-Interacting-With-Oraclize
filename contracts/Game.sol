pragma solidity ^0.4.11;

import "./usingOraclize.sol";

contract Game is usingOraclize {

  //MINIMUM_STAKE allowed is 0.01 ether
  uint public constant MINIMUM_STAKE = 10 ** 16;

  //MAXIMUM_STAKE allowed is 1 ether
  uint public constant MAXIMUM_STAKE = 10 ** 18;

  bytes16 public constant TEAM_A = 'realmadrid';

  bytes16 public constant TEAM_B = 'swansea';

  //Game kickoff
  uint256 public startTime;

  //Game Signoff
  uint256 public endTime;

  //Address that created the contract
  address public owner;

  //Address that bet charges are paid to
  address public beneficiary;

  bool internal closed = false;

  string public winner;
  string public didfetch;

  struct Punter {
    address account;
    uint stake;
    bytes16 supporting;
  }

  Punter[] public bettings;

  mapping (address => uint) public  bettingAddresses;

  mapping (bytes32 => bool) public queryIds;

  modifier onlyOwner() {
    require(msg.sender == owner);

    _;
  }

  modifier ended() {
    require(block.timestamp >= endTime);

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

  modifier validTeam(bytes16 team) {
    require(TEAM_A == team || TEAM_B == team);

    _;
  }

  modifier notClosed() {
    require(closed  == false);

    _;
  }

  event Bet(address account, uint amount);

  event BetClosed(uint timestamp);

  event FetchResult();

  event FetchedResult(bytes16 winner);

  event newOraclizeQuery(string description);

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
  function placeBet(bytes16 team) notStarted validContribution haveNoStake validTeam(team) public payable returns (uint) {
    bettings.push(Punter({
      account: msg.sender,
      stake: msg.value,
      supporting: team
      }));

      bettingAddresses[msg.sender] = bettings.length - 1;

      Bet(msg.sender, msg.value);
    }

    /*
    * @param address
    * @return team
    * @return stake
    */
    function getAccountInfo(address account) public view returns (address, uint, bytes16) {
      uint location = bettingAddresses[account];

      Punter storage info = bettings[location];

      return (info.account,info.stake,info.supporting);
    }

    function getWinner() public ended notClosed payable {
      update();
    }

    function __callback(bytes32 myid, string result) {
      require(msg.sender != oraclize_cbAddress());
      require(queryIds[myid] == true);

      /* if(bytes(result).length != 0) { */
      winner = result;
      closed = true;
      didfetch = 'yes';

      /* delete queryIds[myid]; */

      BetClosed(block.timestamp);
      /* } */
    }

    function update() payable {
      if (oraclize_getPrice("URL") > this.balance) {
        newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
          newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
          bytes32 queryId = oraclize_query("URL", "json(http://api.game.test).winner");

          queryIds[queryId] = true;
        }
      }

    }
