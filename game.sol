// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract StonePaperScissors {
    address public owner;
    uint256 public rewardAmount;
    mapping(address => uint8) public playerChoices;

    enum Move { None, Stone, Paper, Scissors }

    event GameResult(address indexed player, string result, uint256 reward);
    event EtherAdded(address indexed sender, uint256 amount);

    constructor() {
        owner = msg.sender;
        rewardAmount = 0;
    }

    function play(uint8 userChoice) external payable {
        require(msg.value > 0, "Must send ether to play the game");
        require(userChoice >= 1 && userChoice <= 3, "Invalid choice");

        playerChoices[msg.sender] = userChoice;

        if (rewardAmount == 0) {
            rewardAmount = msg.value;
        } else {
            require(msg.value == rewardAmount, "Incorrect ether amount");
        }

        if (address(this).balance >= rewardAmount * 2) {
            determineWinner();
        }
    }

    function determineWinner() internal {
        address player = msg.sender;
        uint8 userChoice = playerChoices[player];
        uint8 computerChoice = uint8(block.timestamp % 3) + 1;

        string memory result;

        if (userChoice == computerChoice) {
            payable(player).transfer(rewardAmount);
            result = "It's a draw! Ether refunded.";
        } else if (
            (userChoice == uint8(Move.Stone) && computerChoice == uint8(Move.Scissors)) ||
            (userChoice == uint8(Move.Paper) && computerChoice == uint8(Move.Stone)) ||
            (userChoice == uint8(Move.Scissors) && computerChoice == uint8(Move.Paper))
        ) {
            payable(player).transfer(rewardAmount * 2);
            result = "Congratulations! You win!";
        } else {
            result = "You lose! Try again.";
        }

        emit GameResult(player, result, rewardAmount);
        rewardAmount = 0;
        delete playerChoices[player];
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

  function addEther() external payable {
        require(msg.sender == owner, "Only owner can add ether");
        emit EtherAdded(msg.sender, msg.value);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
