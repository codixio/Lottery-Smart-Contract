// contract: https://goerli.lineascan.build/address/0x7fb3088006861180fc3cf2c2bc922d21b9099daf

// SPDX-License-Identifier: GPL-3.0

// set Solidity compiler version
pragma solidity >=0.8.2 <0.9.0;

// set contract name
contract LotteryContract {
    address public manager;
    address payable[] public candidates; //addresses are able to receive Either transfers
    address payable public winner;

    constructor(){
        manager = msg.sender; // person who controls this smart contract
    }

    // trigger receive function when new Ether payment has been received
    // can only be called from outside of this contract
    receive() external payable {
        require(msg.value == 0.000001 ether); // to get added to the candidates list, it is required to send 0.000001 Ether exactly
        candidates.push(payable(msg.sender)); // make sure the candidate's address can receive Ether in the future
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager); // only the manager is able to view the current lottery size balance
        return address(this).balance; // returns the current lottery size balance
    }

    function getRandomWinner() public view returns(uint) {
        // add temp. randomness to the winner selection via current block difficulty, 
        // block timestamp and amount of candidates participated in the lottery
        // then create a hash value our of those combined values and return an non negative int
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, candidates.length)));
    }

    function pickWinner() public{
        require(msg.sender == manager); // only the manager is able to call the pickWinner function
        require(candidates.length >= 2); // at least we need to participants into the lottery to pick a winner
        uint rand = getRandomWinner(); // receive a random positive number
        uint index = rand%candidates.length; // modulo select a random number, keep boundaries inside array size
        winner = candidates[index]; // pick the winner
        winner.transfer(getBalance()); // transfer the lottery size to the winner
        candidates = new address payable[](0); // start a new lottery
    }
}