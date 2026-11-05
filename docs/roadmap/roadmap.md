# Vyapaar Labs (`vyapaar-labs`) — Platform Engineering Roadmap

## Phase 1: Foundation & Pure Domain Core (Tiers 0, 1A, 1B)
- [x] **Milestone 1.1 (`vyapaar-core`)**: Migrate and harden Shared Kernel value objects (`Price`, `Quantity`, `Money`, `InstrumentId`, `ClientOrderId`, `AlgoId`, `AccountId`), `Decision` grammar, `DomainEvent`s, and JSON Schema golden vectors.
- [x] **Milestone 1.2 (`vyapaar-risk`)**: Migrate synchronous SEBI pre-trade risk gate (`RiskEngine`, `OtrTracker`, `AlgoIdRegistry`, price band checks, sizing risk gate) with `< 15 µs` p99.99 latency and `proptest` coverage.
- [x] **Milestone 1.3 (`vyapaar-ledger`)**: Migrate and refactor `oms`, `portfolio`, and `journal` with 100% `vyapaar-core` types, zero `tokio` dependencies, aggregate-owned FIFO tax-lot matching, and double-entry balance proptests.

## Phase 2: Market Connectivity & Execution Gateways (Tiers 2A, 2B)
- [ ] **Milestone 2.1 (`vyapaar-market`)**: Migrate `core`, `finance` (Indian market rules & cost model), `normalizer`, `indicators`, `signals`, `feed` (streaming & coalescing), `store` (Arrow/Parquet lakehouse), `loaders`, and 4 broker WebSocket feeds (`zerodha`, `upstox`, `fyers`, `angelone`).
- [ ] **Milestone 2.2 (`vyapaar-exec`)**: Migrate `core` (token-bucket rate limiter & `BrokerExecutor`), `auth` (headless TOTP & eDIS), `slicer` (SEBI freeze-quantity & TWAP/VWAP), `router` (Smart Order Router v2), `audit` (SQLite WAL hash-chained journal), and broker REST executors.

## Phase 3: AI Agent & Central Actor Runtime (Tiers 3A, 3B)
- [ ] **Milestone 3.1 (`vyapaar-agent`)**: Migrate 10 AI crates from `honba-nou` plus implement `vyapaar-agent-tools`, `vyapaar-agent-plugins`, and `vyapaar-agent-report` (Typst tearsheet compiler).
- [ ] **Milestone 3.2 (`vyapaar-runtime`)**: Migrate 9 runtime crates from `honba-ya` (`actors`, `api`, `api-rest`, `backtest`, `config`, `enhancer`, `persistence`, `strategy`, `testing`) plus implement `vyapaar-runtime-jobs`.

## Phase 4: FFI Bridge, Workstations & Python Ecosystem (Tiers 4, 5, 6)
- [x] **Milestone 4.1 (`vyapaar-ffi`)**: Migrate codegen and PyO3/Arrow zero-copy bridge producing `vyapaar` Python wheel and `.pyi` stubs.
- [ ] **Milestone 4.2 (`vyapaar-ui`)**: Migrate Leptos 0.8 WASM Strategy Studio & Futuristic Screener (`vyapaar-ui-app`), implement native Ratatui TUI (`vyapaar-tui`) & CLI (`vyapaar-cli`). *(Retired vyapaar-fe: web UI consolidated under vyapaar-ui WASM & TUI)*
- [ ] **Milestone 4.3 (`vyapaar-{data,adapters,strategies,examples,docs}`)**: Migrate Python packages under PEP 621 clean layout and validate MkDocs Material documentation in `vyapaar-docs`.
