// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title GuessFlow - Simple High/Low Number Game (Beginner, fixed)
/// @notice Educational/demo contract — randomness is NOT secure on-chain.
contract GuessFlow {
    address public owner;
    uint256 public minBet;            // minimum bet in wei
    uint8 public previousNumber;      // 0-99
    uint256 public feeBasisPoints;    // fee taken on wins (e.g., 200 = 2%)
    uint256 public gamesPlayed;

    // simple reentrancy guard
    uint256 private _locked = 1;
    modifier nonReentrant() {
        require(_locked == 1, "reentrant");
        _locked = 2;
        _;
        _locked = 1;
    }

    enum Guess { Low, High }

    event GamePlayed(address indexed player, uint256 bet, uint8 prevNumber, uint8 newNumber, Guess guess, bool won, uint256 payout);
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event MinBetChanged(uint256 newMinBet);
    event FeeChanged(uint256 newFeeBP);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(uint256 _minBetWei, uint256 _feeBasisPoints) {
        require(_feeBasisPoints <= 1000, "fee too high"); // up to 10%
        owner = msg.sender;
        minBet = _minBetWei;
        feeBasisPoints = _feeBasisPoints;
        // initialize previousNumber from some on-chain entropy (demo only)
        previousNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1)))) % 100);
    }

    /// @notice deposit funds to the contract to pay winners
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Play the game by sending an ETH bet and choosing high/low
    /// @param _guess 0 for Low, 1 for High
    function play(Guess _guess) external payable nonReentrant {
        require(msg.value >= minBet, "bet below minimum");
        uint256 bet = msg.value;

        // generate new pseudo-random number 0-99 (insecure — for demo only)
        uint8 newNumber = uint8(uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,        // more modern randomness source if available (still not secure)
            msg.sender,
            bet,
            blockhash(block.number - 1),
            gamesPlayed
        ))) % 100);

        bool won = false;
        uint256 payout = 0;

        if (newNumber == previousNumber) {
            // tie: refund bet
            payout = bet;
            // effects first: update state before external transfer
            previousNumber = newNumber;
            gamesPlayed++;
            // interaction
            payable(msg.sender).transfer(payout);
            emit GamePlayed(msg.sender, bet, previousNumber, newNumber, _guess, false, payout);
            return;
        }

        bool isHigh = newNumber > previousNumber;
        if ((isHigh && _guess == Guess.High) || (!isHigh && _guess == Guess.Low)) {
            // player wins: gross payout = 2 * bet
            uint256 gross = bet * 2;
            uint256 fee = (gross * feeBasisPoints) / 10000;
            payout = gross - fee;
            // effects first: update state before external transfer
            previousNumber = newNumber;
            gamesPlayed++;
            // ensure contract has enough funds (bet already added to balance)
            require(address(this).balance >= payout, "contract out of funds");
            // interaction
            payable(msg.sender).transfer(payout);
            won = true;
            emit GamePlayed(msg.sender, bet, previousNumber, newNumber, _guess, true, payout);
        } else {
            // player loses: contract keeps bet
            payout = 0;
            // update state
            previousNumber = newNumber;
            gamesPlayed++;
            emit GamePlayed(msg.sender, bet, previousNumber, newNumber, _guess, false, payout);
        }
    }

    /* ========== OWNER FUNCTIONS ========== */

    /// @notice Withdraw contract balance (owner only)
    function ownerWithdraw(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= address(this).balance, "not enough balance");
        // effects: none to change here
        payable(owner).transfer(amount);
        emit Withdraw(owner, amount);
    }

    /// @notice Change minimum bet
    function setMinBet(uint256 _minBetWei) external onlyOwner {
        minBet = _minBetWei;
        emit MinBetChanged(_minBetWei);
    }

    /// @notice Change fee (basis points). E.g. 200 => 2%
    function setFeeBasisPoints(uint256 _feeBP) external onlyOwner {
        require(_feeBP <= 1000, "fee too high");
        feeBasisPoints = _feeBP;
        emit FeeChanged(_feeBP);
    }

    /// @notice Owner can transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }

    /* ========== VIEW HELPERS ========== */

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getPreviousNumber() external view returns (uint8) {
        return previousNumber;
    }
}

