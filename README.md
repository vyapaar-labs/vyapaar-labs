# Vyapaar Labs (व्यापार)

**Autonomous, high-throughput, AI-native algorithmic trading and quantitative research platform retargeted for Indian markets (NSE/BSE).**

`vyapaar-labs` is an integrated ecosystem synthesizing high-performance Rust execution engines, pre-trade regulatory risk gating (<15µs), multi-broker market connectivity, zero-copy Arrow memory bridges, and an AI agent brain with local/cloud LLM backends, Ratatui terminal workstation, and WASM studio.

---

## 🏛️ Repository Topology & Subsystems

| Subsystem Repo | Type | Purpose & Scope |
| :--- | :--- | :--- |
| [`vyapaar-core`](./vyapaar-core) | Rust | **Shared Kernel**: Canonical `Decimal` value objects (`Price`, `Quantity`, `Money`), `InstrumentId`, `Tick`, `Order`, `Decision`, OpenAPI schemas. |
| [`vyapaar-ledger`](./vyapaar-ledger) | Rust | **Domain Heart (Zero-I/O)**: Order Management System (`oms`), FIFO tax-lot tracking (`portfolio`), double-entry general ledger (`journal`). |
| [`vyapaar-risk`](./vyapaar-risk) | Rust | **Regulatory Risk Gate**: Sub-15 µs pre-trade risk engine (SEBI algo ID, OTR circuit breakers, scrip price bands, freeze limits, kill-switch). |
| [`vyapaar-market`](./vyapaar-market) | Rust | **Market Data**: Multi-broker binary WebSockets (Zerodha, Upstox, Angel One, Fyers), tick coalescing, 100+ indicators, Parquet loaders, macro/finance series. |
| [`vyapaar-exec`](./vyapaar-exec) | Rust | **Execution Gateway**: First-party broker executors, headless TOTP auth, freeze slicer, Smart Order Router (SOR), hash-chained fsynced audit journal (JSONL segment WAL). |
| [`vyapaar-runtime`](./vyapaar-runtime) | Rust | **Central Runtime & Automation**: Tokio actor pipeline, event-driven backtester, strategy enhancer (GA/WFO), Axum REST/WS API, cron/background jobs, SQLite & git2 snapshots. |
| [`vyapaar-agent`](./vyapaar-agent) | Rust | **AI Agent & Agent Engine**: Local/cloud LLMs (Anthropic/OpenAI), trader loop, prompt replay, genetic synthesizer, MCP (`rmcp`), agent tools, plugin marketplace, embedded Typst reports. |
| [`vyapaar-ffi`](./vyapaar-ffi) | Rust (PyO3) | **Python FFI Bridge**: Apache Arrow zero-copy memory bridge and smart GIL management. Builds the `vyapaar` PyPI wheel. |
| [`vyapaar-ui`](./vyapaar-ui) | Rust (WASM + TUI) | **Unified Workstations**: WASM/Native Shell Strategy Studio & Screener (`ui-app`), `openalgo-charts-rs`, Ratatui Terminal UI (`vyapaar-tui`), CLI binary (`vyapaar-cli`), tree-sitter highlighter. |
| [`vyapaar-strategies`](./vyapaar-strategies) | Python | **Production Strategies**: Catalog of institutional strategies (Quoting, Arbitrage, TWAP/VWAP slicers, Turtle breakout, Risk Parity). |
| [`vyapaar-adapters`](./vyapaar-adapters) | Python | **Broker SDK**: Pluggable Python community broker connectors (Dhan, Zerodha, Upstox, Angel One, Fyers, Kotak, IIFL). |
| [`vyapaar-data`](./vyapaar-data) | Python + DuckDB | **Data Lakehouse**: Point-in-time corporate actions, splits, dividends, coverage ledgers, Parquet catalog, data ingestion sidecars. |
| [`vyapaar-examples`](./vyapaar-examples) | Python | **Learning Path**: Runnable reference scripts for Indian equities, options, factor models, and backtesting. |
| [`vyapaar-docs`](./vyapaar-docs) | Markdown | **Documentation**: Comprehensive architecture, API references, tutorials, and user guides built via MkDocs Material. |

---

## 🚀 Superproject Structure

`vyapaar-labs` serves as the superproject repository tracking each subsystem as an autonomous Git submodule while allowing atomic cross-subsystem orchestration:

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/vyapaar-labs/vyapaar-labs.git
cd vyapaar-labs

# Build all Rust production targets
make prod

# Run test suites across all workspaces
make test
```

## 📜 Invariants & Philosophy

1. **Zero-I/O Domain Purity**: `vyapaar-ledger` and `vyapaar-risk` have zero network, database, or disk I/O.
2. **Strict Zero-Floats**: `rust_decimal::Decimal` and Python `decimal.Decimal` are strictly enforced across all prices, quantities, and balances.
3. **SEBI Regulatory First-Class**: Algo ID tracking, Order-to-Trade Ratio (OTR) circuit breakers, and price band validation are mandatory.
4. **Dual Workstations**: Single static binary terminal chat/assistant (`vyapaar ask`, `vyapaar tui`) and high-density WASM canvas (`vyapaar-ui`).
