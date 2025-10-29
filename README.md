# 🎲 GuessFlow — High/Low Number Challenge on Blockchain  


<img width="1920" height="1080" alt="Screenshot (9)" src="https://github.com/user-attachments/assets/334b6285-5498-4c22-871d-25ad7bbbc6db" />
https://sepolia.celoscan.io/tx/0x4ca9df4af915f209ec338ada4d935816f190dc6563f54b304f0c34fb53e9d058
## 🚀 Project Description  

**GuessFlow** is a decentralized **High-Low number guessing game** built on the Ethereum blockchain.  
Players try to predict whether the next randomly generated number will be **higher** or **lower** than the previous one.  

This project demonstrates how to:
- Write and deploy a basic Solidity smart contract  
- Use pseudo-randomness in smart contracts (for demo purposes)  
- Handle Ether transactions (bets, payouts, and fees)  
- Manage contract ownership and security  

It’s perfect for **Solidity beginners** learning how blockchain-based games work!  

---

## 🎯 What It Does  

1. Players send a small ETH bet to the contract.  
2. They choose **High** or **Low** as their guess.  
3. The contract generates a new number (0–99).  
4. If the player’s prediction is correct — they **win 2x their bet (minus a small fee)**.  
5. If it’s a tie, the bet is refunded.  
6. If they lose, the contract keeps the bet.  
7. The owner can set the minimum bet, fees, and withdraw funds.  

> ⚠️ **Note:** Randomness in this contract is *pseudo-random* and **not secure for real-money use**.  
For production, integrate **Chainlink VRF** or another secure randomness oracle.  

---

## ✨ Features  

✅ **Simple High/Low Betting Logic** — easy to understand and fun to play  
✅ **Owner Controls** — manage minimum bet and house fee  
✅ **Event Logging** — every game is recorded on the blockchain  
✅ **Automatic Payouts** — winners are paid instantly  
✅ **Reentrancy Guard** — basic protection against reentrancy attacks  
✅ **Educational Value** — great for students learning Solidity  

---

## 🧠 Smart Contract Code  

```solidity

