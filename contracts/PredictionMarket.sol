// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// pragma solidity ^0.7.3;

contract PredictionMarket {
  enum Side { Imran_Khan, Shehbaz_Sharif }
  struct Result {
    Side winner;
    Side loser;
  }
  Result result;
  bool electionFinished; // to tell if election is finished

  
  mapping(Side => uint) public bets; // global bet
  mapping(address => mapping(Side => uint)) public betsPerGambler;
  address public oracle; // stores result of election

  constructor(address _oracle) { // oracle address passed as argument
    oracle = _oracle; 
  }
  // function to place bet and take argument which side you want to bet
  function placeBet(Side _side) external payable {
    require(electionFinished == false, 'election is finished'); // after election no bet
    bets[_side] += msg.value;
    betsPerGambler[msg.sender][_side] += msg.value;
  }

  function withdrawGain() external {
    uint gamblerBet = betsPerGambler[msg.sender][result.winner];
    require(gamblerBet > 0, 'you do not have any winning bet');  
    require(electionFinished == true, 'election not finished yet');
    uint gain = gamblerBet + bets[result.loser] * gamblerBet / bets[result.winner];
    betsPerGambler[msg.sender][Side.Imran_Khan] = 0;
    betsPerGambler[msg.sender][Side.Shehbaz_Sharif] = 0;
    payable(msg.sender).transfer(gain);
  }

  function reportResult(Side _winner, Side _loser) external {
    require(oracle == msg.sender, 'only oracle');
    result.winner = _winner;
    result.loser = _loser;
    electionFinished = true;
  }
}