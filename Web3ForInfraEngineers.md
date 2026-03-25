# Web3 Is Just Infrastructure With a Hoodie

Everything in Web3 is something you already know. It's wearing a hoodie, it grew a beard, and it's pretending it just got invented. I'm not being dismissive -- there are genuinely novel ideas in this space. But they're buried under so many layers of rebranding that experienced infrastructure engineers bounce off the terminology and assume the whole thing is alien. It isn't.

I've spent my career building cryptographic infrastructure: PKI at U.S. Bank, Vault-backed certificate authorities at Orion Labs, managed secrets systems at Scribd, and most recently, the entire security and infrastructure stack for a cryptocurrency trading platform handling real customer funds across multiple hybrid cloud and bare-metal Kubernetes clusters. I also built [kubectl-ssh-oidc](https://github.com/nikogura/kubectl-ssh-oidc) and a [Dex SSH connector](https://github.com/nikogura/dex), which bridge SSH key identity into OIDC tokens via RFC 8693 token exchange. I built [DBT](DBT.md), which implements a full chain-of-trust for signed binary distribution. Every one of these systems solves the same fundamental problem that blockchains solve: prove who you are, prove you authorized this action, and make it verifiable by anyone without trusting a central authority more than you have to.

The thesis of this piece is simple: **wallet signing is SSH authentication v2.** The same ECDSA private key that proves your identity in an SSH handshake proves your ownership of funds in a blockchain transaction. The only differences are the serialization format and the curve parameters. If you understand SSH, you understand wallets. If you understand Vault, you understand on-chain key management. If you understand GitOps, you understand why blockchains care so much about deterministic state.

Let me show you.

## The Concept Map

Here's the cheat sheet. Every Web3 concept on the left has a direct equivalent on the right:

- **Wallet** = a private key. That's it. Your wallet *is* your ECDSA private key (secp256k1 curve). Your "address" is derived from the public key (last 20 bytes of the keccak256 hash). Same concept as SSH key identity -- the key *is* the identity. When I built kubectl-ssh-oidc, I was doing exactly what a wallet does: signing a JWT with an SSH private key to prove identity. A blockchain wallet signs a transaction with a private key to prove authorization. Same primitive, different wire format.

- **Signing a transaction** = exactly what you do with SSH signatures. You construct a message (the transaction), sign it with your private key, and anyone can verify the signature against your public key. The only difference is the serialization format (RLP encoding instead of SSH wire format). I've literally built this bridge -- kubectl-ssh-oidc signs JWTs with SSH keys, Dex verifies them against admin-configured public keys, and out comes an OIDC token. Replace "JWT" with "transaction" and "OIDC token" with "block inclusion" and you've described Ethereum.

- **Smart contract** = a program deployed at an address. When you send a transaction to that address with specific calldata, the EVM (Ethereum Virtual Machine) executes the bytecode deterministically. Think of it as an RPC endpoint where the server code is public, immutable, and runs on every node simultaneously. The "trust somebody else's computer" problem is solved by running it on *everybody's* computer and requiring consensus on the result.

- **Gas** = you're paying for compute. Every EVM opcode has a gas cost. Gas price fluctuates with demand. It's metered compute, same concept as AWS Lambda billing per millisecond, except the price is set by a real-time auction.

- **Ethereum itself** = a replicated state machine where every node holds the same state (account balances, contract storage) and every state transition (transaction) must be cryptographically signed and validated by consensus before it's accepted. If you've ever operated a multi-master database or a consensus-based distributed system, this is familiar territory.

## The Trust Model: Verify, Don't Trust

This is where my [DBT](DBT.md) experience is directly relevant. DBT implements a chain-of-trust for software distribution: every binary is GPG-signed, every signature is verified against an administrator-controlled truststore, and nothing executes until verification passes. The trust model is "verify before you run." Blockchains do the same thing for financial transactions: every transaction is cryptographically signed, every signature is verified by every node, and nothing changes state until verification passes.

The parallel to [kubectl-ssh-oidc](https://github.com/nikogura/kubectl-ssh-oidc) is even more direct. In that system, the trust architecture separates authentication (cryptographic proof via SSH signature) from authorization (administrator policy in Dex). The client proves key ownership; the server decides what that identity is allowed to do. Blockchains work identically: your wallet signature proves you own the funds (authentication), and the smart contract logic determines what you're allowed to do with them (authorization). The separation is the same. The cryptographic primitives are the same. The trust model is the same.

## L1 vs L2: The Scaling Problem You've Already Seen

### Layer 1 (L1)

L1 is the base chain -- Ethereum mainnet. Every transaction must be validated by every full node. This is the fundamental scalability bottleneck of any replicated state machine: throughput is bounded by what the slowest honest node can process.

Ethereum L1 does roughly 15-30 transactions per second. That's not a bug, it's the tradeoff for maximum decentralization and security. If you've ever operated a consensus-based system and watched throughput drop as you added more replicas, you've seen this before.

### Layer 2 (L2)

L2 is the same pattern as offloading work from a primary database to a read replica or cache, then periodically syncing back. L2s execute transactions off the main chain, batch the results, and post a compressed summary (or proof) back to L1.

The key insight: **L2s inherit L1's security guarantees** because the L1 can verify the L2's work. How they verify differs:

### Optimistic Rollups (Optimism, Arbitrum)

Post transaction batches to L1 and assume they're valid. There's a challenge period (typically 7 days) where anyone can submit a fraud proof showing the batch was invalid. If nobody challenges, it's finalized. This is exactly like an audit model -- trust but verify, with penalties for fraud.

### ZK Rollups (zkSync, Polygon zkEVM, Starknet)

Post transaction batches WITH a zero-knowledge proof that mathematically proves the state transition is valid. No challenge period needed -- the proof is verified on-chain. This is closer to what you'd recognize as cryptographic verification: the proof is a mathematical guarantee, not an economic one.

### Polygon

Polygon started as a sidechain (its own consensus, not strictly an L2) but has been evolving toward a ZK-based architecture. Polygon PoS (the current main chain) runs its own proof-of-stake consensus with its own validators, but periodically checkpoints state to Ethereum L1. It's faster and cheaper than L1 but has weaker security guarantees than a true rollup -- you're trusting Polygon's validator set, not Ethereum's.

## Consensus: Two Sybil Resistance Mechanisms

### Proof of Work (Bitcoin, old Ethereum)

To propose a block, you must find a nonce that makes the block hash meet a difficulty target. This is computationally expensive by design -- it's a Sybil resistance mechanism. You can't fake identity because identity is measured in hashrate, which costs real energy.

### Proof of Stake (current Ethereum, Polygon)

Instead of proving you burned energy, you prove you have economic skin in the game by locking up (staking) tokens as collateral. If you validate honestly, you earn rewards. If you validate dishonestly (sign conflicting blocks, go offline), your stake gets slashed (destroyed).

Proof of stake is an economic security model, not a cryptographic one. It's like a performance bond -- you put up collateral that gets seized if you breach the contract. The "trust" isn't in the math (like a ZK proof), it's in the economic incentive: attacking the network requires acquiring and risking enough stake that the attack costs more than it gains.

### Staking in Practice

- You lock 32 ETH (or delegate to a pool) to run a validator node
- You sign attestations (votes on block validity) and occasionally propose blocks
- Rewards: ~3-5% APR on staked ETH, paid in ETH
- Slashing risk: lose a portion of your stake for misbehavior
- The signing is literally BLS signatures on beacon chain messages -- same cryptographic primitive, different context

### Liquid Staking (Lido, Rocket Pool)

You deposit ETH, get a derivative token (stETH, rETH) that represents your staked position. The derivative token is tradeable, so your capital isn't locked. It's like a certificate of deposit that's tradeable on a secondary market.

## DEXs: Decentralized Exchanges

A DEX is a smart contract that facilitates token swaps without a central order book or custodian. There are two main models:

### Automated Market Maker (AMM)

This is the Uniswap model. Instead of matching buyers and sellers (order book), liquidity providers deposit token pairs into pools, and a mathematical formula determines the price.

**The constant product formula:** `x * y = k`

Where `x` is the reserve of token A, `y` is the reserve of token B, and `k` is a constant. When you buy token A, you add token B to the pool and remove token A. The ratio changes, which changes the price.

```
Pool: 1000 ETH / 2,000,000 USDC
Implied price: 2000 USDC/ETH
k = 1000 * 2,000,000 = 2,000,000,000

You buy 10 ETH:
New ETH reserve: 990
New USDC reserve: k / 990 = 2,020,202.02
You paid: 20,202.02 USDC for 10 ETH (effective price: 2,020.20/ETH)
```

The price slipped because your trade moved the ratio. Larger trades relative to pool size = more slippage. This is why liquidity depth matters.

This is a stateless pricing function -- no order book state to maintain, no matching engine, no priority queue. The "order book" is implicit in the reserves. It's elegant from a distributed systems perspective because it eliminates the coordination problem of order matching across replicated state.

### Order Book DEX

Some DEXs (dYdX, Serum) use on-chain or hybrid order books. Limit orders are placed as signed messages, and a matching engine (sometimes off-chain) pairs them. Closer to traditional finance, but more complex to decentralize.

## Providing Liquidity: Being the Market Maker

When someone "provides liquidity," they're depositing token pairs into an AMM pool. In return, they get LP (Liquidity Provider) tokens representing their share of the pool.

**Why would you do this?** You earn a fee on every swap. Uniswap v2 charges 0.3% per trade, distributed pro-rata to LPs. If the pool does $1M in daily volume, LPs collectively earn $3,000/day.

### Impermanent Loss

You deposit 1 ETH + 2000 USDC (50/50 by value) when ETH is $2000. If ETH price doubles to $4000, arbitrageurs rebalance the pool so your position is now ~0.707 ETH + 2828 USDC. Total value: $5,656.

If you had just *held* 1 ETH + 2000 USDC, you'd have $6,000.

The $344 difference is impermanent loss. It's "impermanent" because if the price returns to $2000, the loss disappears. It becomes permanent if you withdraw at the diverged price.

Providing liquidity is functionally being a market maker. You're offering to buy and sell at algorithmically determined prices, earning the spread (fees) in exchange for taking inventory risk (impermanent loss). Traditional market makers do the same thing with different tooling.

## The Rebranding Problem

This is the table I wish someone had given me. Every Web3 term on the left is a concept you already know on the right:

| Web3 Term | What It Actually Is |
|-----------|-------------------|
| ERC-20 | An interface standard. A smart contract that implements `transfer()`, `approve()`, `balanceOf()`, etc. It's literally a Go interface -- any contract implementing these methods is an "ERC-20 token." |
| ERC-721 (NFT) | Same pattern but with unique token IDs. Each token has a distinct owner. It's a registry mapping IDs to addresses. |
| Approve/Allowance | Delegated authorization. You sign a transaction saying "contract X can spend up to N of my tokens." Exactly like an OAuth scope grant. |
| Wrapped tokens (WETH) | ETH doesn't conform to ERC-20 (it's the native currency, not a contract). WETH is a contract that holds your ETH and gives you an ERC-20 representation. It's an adapter pattern. |
| Bridge | Transfers tokens between chains. Lock tokens on chain A, mint equivalent on chain B. It's a federated escrow system with various trust models. |
| Oracle | An off-chain data feed posted on-chain. Chainlink is the dominant provider. It's an API call, except the "API" is a committee of nodes that sign price data and the "response" is written to contract storage. |
| Governance token | A token where `balanceOf(address)` determines your voting weight on protocol changes. Token-weighted democracy. |
| Yield farming | Providing capital to protocols in exchange for token rewards. The protocol pays you in its own governance token to attract liquidity. It's a customer acquisition cost paid in equity. |
| TVL (Total Value Locked) | Sum of all assets deposited in a protocol's smart contracts. It's AUM (Assets Under Management) rebranded. |
| MEV (Maximal Extractable Value) | Validators can reorder transactions within a block to profit from arbitrage. It's front-running, but structural -- the mempool is public, so pending transactions are visible before inclusion. |

## Blockchain Reorganizations (Reorgs)

Reorgs sound like they shouldn't work -- reordering a state machine sounds like a recipe for disaster. The key insight is that a reorg doesn't reorder transactions within the existing chain. It **replaces a suffix of the chain with an alternative suffix**, then replays the state machine from the fork point.

If you've ever dealt with optimistic concurrency control in databases, this is the same pattern. You optimistically process transactions assuming no conflicts. If a conflict is detected (a heavier fork appears), you roll back to the last consistent snapshot and replay with the winning transaction set.

### What Actually Happens

A blockchain reorg occurs when two (or more) valid blocks are produced at roughly the same height, creating a temporary fork. Different nodes see different blocks first, so for a brief period the network disagrees on the "tip" of the chain. When one fork accumulates more weight (more blocks built on top, or more attestations in PoS), the network converges on the heavier fork and **abandons** the lighter one.

```
Block 100 -> Block 101a -> Block 102a -> Block 103a  (heavier fork, wins)
                \
                 Block 101b -> Block 102b            (lighter fork, orphaned)
```

If your node was following the 101b fork, a reorg means:

1. **Roll back** state to block 100 (the last common ancestor)
2. **Replay** blocks 101a, 102a, 103a to compute the new canonical state
3. **Discard** blocks 101b, 102b -- transactions in those blocks are now "unconfirmed"

Transactions from the orphaned fork go back to the mempool. Most will be re-included in the winning fork (they're still valid transactions). But some might conflict -- if 101b contained a transaction spending the same funds as a transaction in 101a, only one survives.

Every full node maintains enough state history to roll back to recent ancestors. Ethereum nodes typically keep state for recent blocks (128 blocks by default for most clients). This is the same pattern as a database WAL (Write-Ahead Log) -- you can replay forward from a snapshot, or roll back by reversing recent operations.

### The Finality Spectrum

Different chains handle finality differently:

**Bitcoin**: Purely probabilistic. Every additional block on top of your transaction makes a reorg exponentially less likely, but never impossible. The convention of "6 confirmations" means 6 blocks deep -- at that depth, the cost of producing an alternative heavier chain exceeds the economic incentive for almost any attacker. But it's still probabilistic, not deterministic.

**Ethereum (post-Merge)**: Two-tier finality. Blocks are proposed every 12 seconds and are subject to reorgs for 2 epochs (~12.8 minutes). After that, the Casper FFG finality gadget "finalizes" the block -- meaning 1/3+ of all staked ETH would need to be slashed (destroyed) to revert it. This is **economic finality**: not mathematically impossible to revert, but the cost is so catastrophic (~$10B+ at current stake) that it's effectively final.

**Polygon PoS**: Checkpoints to Ethereum L1 every ~30 minutes. Within Polygon, blocks finalize quickly (a few seconds with their BFT consensus), but the strongest guarantee comes when the checkpoint is finalized on Ethereum. Between checkpoints, you're trusting Polygon's validator set.

**Tendermint/CometBFT chains**: Instant finality. Blocks are not produced until 2/3+ of validators have pre-committed. No forks, no reorgs, but the tradeoff is that the chain halts entirely if 1/3+ of validators go offline.

### Why This Matters If You're Building an Exchange

For a system with both a DEX (on-chain) and an exchange (off-chain components):

**DEX (on-chain)**: Reorgs are handled transparently by the blockchain. If a swap gets reorged, it either gets re-included in the new fork or it doesn't. The AMM's state is always consistent because the state machine replays deterministically. Users might see a confirmed swap "disappear" and then "reappear" -- confusing UX, but not a consistency violation.

**Exchange (off-chain components)**: This is where reorgs are dangerous. If your exchange credits a user's account based on a deposit transaction that later gets reorged out, you've credited funds that don't exist. This is the classic **double-spend attack vector** -- the attacker deposits, gets credited, withdraws or trades, then the deposit transaction disappears in a reorg.

### Practical Engineering Requirements

1. **Confirmation thresholds**: Don't treat deposits as final until N confirmations deep. On Polygon, wait for the Ethereum checkpoint for high-value transactions. On Ethereum L1, wait for finalization (~12.8 minutes).

2. **Reorg detection**: Your indexer/event processor must detect when the chain tip changes and re-process affected blocks. This means your event processing must be **idempotent** -- processing the same event twice (once on the orphaned fork, once on the winning fork) must produce the correct result.

3. **State reconciliation**: If you're maintaining off-chain state derived from on-chain events, you need a reconciliation process that can roll back off-chain state when on-chain state is reorged. Same pattern as eventual consistency in distributed databases -- your off-chain state is a materialized view that must stay consistent with the source of truth (the chain).

4. **Idempotent transaction processing**: Every on-chain event your system processes should be keyed by `(block_hash, transaction_hash, log_index)`, not just `transaction_hash`. A transaction can appear in different blocks during a reorg, and the block hash distinguishes which version is canonical.

5. **Nonce management**: If you're submitting transactions and a reorg occurs, your pending transactions might conflict with the new chain state. Your transaction submission system needs to detect stuck/conflicting transactions and resubmit with correct nonces.

The engineering pattern is: **treat on-chain state as an eventually consistent external system**, apply the same defensive patterns you'd use with any distributed data source (idempotency, reconciliation, confirmation thresholds), and never assume a recent block is permanent.

## What's Actually New

The rebranding is thick, but three things are genuinely novel:

1. **Programmable money with atomic composability** -- smart contracts can call other smart contracts in a single transaction, enabling complex financial operations that either fully succeed or fully revert. No partial state. This is actually new. Databases have transactions, but they don't compose across trust boundaries like this.

2. **Permissionless deployment** -- anyone can deploy a contract and it's available to everyone. No API key, no approval process. No gatekeeper. This changes the dynamics of what gets built and by whom.

3. **Transparent state** -- all contract storage is publicly readable. This changes the security model fundamentally (no security through obscurity). If you're used to securing systems by hiding implementation details, this forces a different discipline.

Everything else -- the cryptography, the distributed consensus, the key management, the RPC calls, the client libraries -- is traditional distributed systems engineering. The domain language is finance, the implementation is distributed systems, and the trust model is "verify, don't trust."

That last part -- "verify, don't trust" -- is the same principle that drives [DBT's](DBT.md) chain-of-trust, [kubectl-ssh-oidc's](https://github.com/nikogura/kubectl-ssh-oidc) cryptographic identity model, Vault's policy engine, and every GitOps system that refuses to let you `kubectl apply` from your laptop. The blockchain world just branded it "trustless" and acted like they invented it.

They didn't. But they did find a way to apply it to money, and that part is worth paying attention to.
