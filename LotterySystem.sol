// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    
    uint256 ticketPrice;
    uint256 public ticketCount;
    uint256 public lotteryNumber;
    address[] public ticketHolders;
    
    mapping(address => uint256) public ticketsOwned;
    
    event TicketPurchased(address indexed purchaser, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 prize);
    
    constructor(uint256 _ticketPrice) {
        ticketPrice = _ticketPrice;
        ticketCount = 0;
    }
    
    /**
     * @dev Allows a user to purchase tickets for the lottery.
     * The number of tickets purchased is determined based on the sent value divided by the ticket price.
     * Emits a `TicketPurchased` event.
     */
    function purchaseTicket() public payable {
        require(msg.value >= ticketPrice, "Insufficient value to purchase a ticket");
        
        uint256 numOfTickets = msg.value / ticketPrice;
        ticketHolders.push(msg.sender);
        ticketsOwned[msg.sender] += numOfTickets;
        ticketCount += numOfTickets;
        
        emit TicketPurchased(msg.sender, numOfTickets);
    }
    
    /**
     * @dev Generates a random number based on the provided seed.
     * The random number is calculated using the seed and the total number of tickets sold.
     * Requires at least one ticket to be sold.
     *
     * Addon this is called solo random generation method for generating random numbers which is unique
     * Other types include True Random number generator and Pseudo Random Number generator methods
     * 
     * @param seed The seed value for generating the random number.
     * @return A random number within the range of the total number of tickets sold.
     */
    function generateRandomNumber(uint256 seed) internal view returns (uint256) {
        require(ticketCount > 0, "No tickets sold");
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed)));
        return randomNumber;
    }
    
    /**
     * @dev Selects a winner for the lottery.
     * Generates a random number based on the current block timestamp.
     * The winner is selected from the list of ticket holders using the generated random number.
     * Transfers the prize amount to the winner and emits a `WinnerSelected` event.
     * Requires the caller to be the contract owner.
     */
    function selectWinner() public onlyOwner {
        require(ticketCount > 0, "No tickets sold");
        
        uint256 winningIndex = generateRandomNumber(block.timestamp);
        address winner = ticketHolders[winningIndex];
        
        lotteryNumber = winningIndex;
        uint256 prize = ticketCount * ticketPrice;
        
        emit WinnerSelected(winner, prize);
        
        payable(winner).transfer(prize);
        
        resetLottery();
    }
    
    /**
     * @dev Resets the lottery by clearing the ticket holders array and setting the ticket count to zero.
     * This function is called after a winner is selected to prepare for a new round.
     * Internal function, not meant to be called directly outside the contract.
     */
    function resetLottery() internal {
        ticketHolders = new address[](0);
        ticketCount = 0;
    }
}
