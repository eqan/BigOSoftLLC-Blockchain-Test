// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "hardhat/console.sol";
import "../contracts/LotterySystem.sol";

contract LotteryTest {

    uint256 ticketPrice = 1 ether;

    Lottery lotteryToTest;

    function beforeAll() public {
        lotteryToTest = new Lottery(ticketPrice);
    }

    function checkInitialTicketCount() public {
        Assert.equal(lotteryToTest.ticketCount(), uint256(0), "Initial ticket count should be 0");
    }

    function checkTicketPurchase() public {
        address addr1 = payable(address(this));
        addr1.call{value: ticketPrice}(
            abi.encodePacked(lotteryToTest.purchaseTicket.selector)
        );
        Assert.equal(lotteryToTest.ticketCount(), uint256(1), "Ticket count should be 1 after purchasing");
        Assert.equal(lotteryToTest.ticketsOwned(addr1), uint256(1), "Address should own 1 ticket after purchasing");
    }

    function checkSelectWinner() public {
        lotteryToTest.selectWinner();
        address winner = lotteryToTest.ticketHolders(lotteryToTest.lotteryNumber());
        Assert.equal(lotteryToTest.ticketsOwned(winner), uint256(0), "Winner's tickets should be 0 after lottery ended");
    }

    function checkResetLottery() public {
        Assert.equal(lotteryToTest.ticketCount(), uint256(0), "Ticket count should be reset to 0 after lottery ended");
    }
}
