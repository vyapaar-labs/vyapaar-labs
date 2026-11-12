# Vyapaar Labs (`vyapaar-labs`) — Domain-Driven Design (DDD) Architecture

## 1. Strategic DDD: Bounded Contexts & Ubiquitous Language

`vyapaar-labs` partitions the algorithmic trading and quantitative research domain into **15 strictly bounded repositories** organized across 6 architectural layers:

| Layer | Bounded Context Repo | Core Responsibility | I/O Policy |
| :---: | :--- | :--- | :--- |
| **L0** | `vyapaar-core` | **Shared Kernel**: Canonical `Decimal` Value Objects (`Price`, `Quantity`, `Money`), Strongly-Typed IDs (`InstrumentId`, `ClientOrderId`, `AlgoId`, `AccountId`), Wire DTOs, `Decision` grammar, `DomainEvent`s, and Port traits. | **Zero-I/O** |
| **L1** | `vyapaar-risk` | **Regulatory Risk Gate**: Sub-15 µs synchronous pre-trade gate (SEBI Algo ID registry, OTR circuit breakers, scrip price bands, freeze limits, emergency kill-switch). | **Zero-I/O** |
| **L1** | `vyapaar-ledger` | **Domain Heart**: Order Management System (`oms`), FIFO tax-lot & T+1 Demat settlement accounting (`portfolio`), Double-Entry General Ledger (`journal`), and pure Repository traits. | **Zero-I/O** |
| **L2** | `vyapaar-market` | **Market Eye**: Market microstructure rules (`finance`), incremental indicators (`indicators`), alpha signals (`signals`), symbol normalizer (`normalizer`), live feeds (`feed`), Parquet lakehouse (`store`), and broker WebSocket ACLs. | Compute: **Zero-I/O**<br>Adapters/Store: Async I/O |
| **L2** | `vyapaar-exec` | **Execution Hand**: Token-bucket rate limiter (`core`), headless TOTP/eDIS auth (`auth`), freeze slicer (`slicer`), Smart Order Router (`router`), tamper-evident hash-chained JSONL audit journal (`audit`), and broker REST ACLs. | Async I/O |
| **L3** | `vyapaar-agent` | **AI Agent**: Closed-grammar LLM providers (`llm`), prompt templates (`prompt`), SHA-256 deterministic replay (`replay`), trader loop (`trader-loop`), genetic synthesizer (`genetic`), MCP server (`mcp`), tools, plugins, and Typst reports (`report`). | Async I/O + Pure Core |
| **L3** | `vyapaar-runtime` | **Central House**: Supervised Tokio actor pipeline (`actors`), event-driven backtester (`backtest`), strategy runner (`strategy`), GA/WFO enhancer (`enhancer`), SQLite/Postgres repositories (`persistence`), cron jobs (`jobs`), and Axum OpenAPI 3.1 server (`api-rest`). | Async I/O |
| **L4** | `vyapaar-ffi` | **Python FFI Bridge**: Schema codegen (`codegen`) and PyO3 + Apache Arrow PyCapsule zero-copy extension (`py`) compiling the `vyapaar` wheel. | FFI Bridge |
| **L5** | `vyapaar-ui` | **Unified Workstations**: Leptos 0.8 WASM Strategy Studio & Screener (`ui-app`), HTML5 canvas charts (`ui-charts`), Ratatui TUI (`tui`), and native CLI (`cli`). | WASM / TUI |
| **L6** | `vyapaar-data` | **Financial Lakehouse**: DuckDB point-in-time fundamentals, corporate actions, and Parquet catalog management. | Python + DuckDB |
| **L6** | `vyapaar-adapters` | **Community Broker SDK**: Pluggable Python broker adapters (Dhan, Zerodha, Upstox, Angel One, Fyers, Kotak, IIFL). | Python I/O |
| **L6** | `vyapaar-strategies`| **Strategy Catalog**: Production Python strategies & declarative `step.toml` catalog chains. | Python Pure |
| **L6** | `vyapaar-examples` | **Learning Path**: Deterministic runnable tutorials for Indian equities, F&O, WFO/DSR, and AI research. | Python |
| **L6** | `vyapaar-docs` | **Documentation**: MkDocs Material technical reference and conformance matrix. | Static Docs |

---

## 2. Tactical DDD Invariants

1. **Zero-I/O Domain Purity**: `vyapaar-core`, `vyapaar-risk`, `vyapaar-ledger`, `vyapaar-market-{indicators,signals,normalizer,finance}`, and `vyapaar-runtime-strategy` must never perform network, disk, database, or wall-clock (`Utc::now()`, `Instant::now()`) calls.
2. **Strict Zero-Floats Policy**: `f32`/`f64` (Rust) and `float` (Python) are banned for prices, quantities, cash balances, fees, taxes, and margins. All monetary/quantity values use `rust_decimal::Decimal` / `decimal.Decimal` wrapped in `Price`, `Quantity`, and `Money`.
3. **Self-Validating Immutable Value Objects**: Value objects validate invariants at construction and deserialization boundaries (e.g., non-negative `Price`, non-negative `Quantity`, valid `InstrumentId`, non-empty SEBI `AlgoId`).
4. **Rich Domain Aggregates**: State mutations happen exclusively through Aggregate Root domain methods (`order_book.apply_fill(...)`, `portfolio.apply_fill(...)`, `ledger.post(...)`, `risk_engine.check_order(...)`) that enforce invariants and emit immutable `DomainEvent`s.
5. **Anti-Corruption Layers (ACL)**: Broker-specific wire formats (Zerodha binary packets, Upstox Protobuf, Angel One SmartAPI JSON) are strictly confined to adapter crates and immediately translated into `vyapaar-core` canonical models.
6. **Parallel Test Directory Rule**: All tests reside in `<crate>/tests/` parallel to `<crate>/src/`. Inline `#[cfg(test)]` blocks inside `src/` are strictly forbidden.
