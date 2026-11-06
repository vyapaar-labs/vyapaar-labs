# Fincept / Quantcepts → Vyapaar concept mapping

Status: draft inventory, not a decision record. Produced by crawling `docs.fincept.in`
(Fincept MCP: 18 toolsets / 443 tools + 17 standalone analytics engines) and the local
`~/tmp/FinceptTerminal` repo (Qt/C++ desktop terminal, AGPL-3.0), then cross-checking
against the actual crate layout of the 13 `vyapaar-*` submodules (not just `AGENTS.md`'s
description of them).

**Open question, not resolved here**: `FinceptTerminal`'s own README lists **Quantcept**
(quantcept.io) as a *separate* hosted product ("AI research desk for markets") distinct
from the desktop terminal — so "the UI and implementation behind quantcepts" may only be
partially represented by this repo. `~/tmp/quantcept-re` (extracted output of a packaged
app, possibly that product) was excluded from this pass per your call. If quantcept.io's
own surface matters, it needs its own pass.

Status legend:
- **Direct** — Vyapaar already has a working equivalent; no design change needed.
- **With changes** — a related Vyapaar module exists but needs redesign/extension to cover the concept.
- **Planned** — concept is named or stubbed in a roadmap/ADR/design doc but not implemented.
- **Gap** — nothing in Vyapaar today; would be new domain surface.

---

## 1. Platform / MCP infrastructure conventions

| Fincept concept | What it is | Vyapaar status | Notes |
|---|---|---|---|
| Hosted MCP server, OAuth 2.1, Streamable HTTP | Agents connect once, call tools as the signed-in account | **With changes** | `vyapaar-agent/crates/vyapaar-agent-mcp` already has `server.rs`, `transport.rs`, `tools.rs`. Need to confirm its transport/auth model matches (currently unverified — likely stdio/local, not a multi-tenant OAuth-gated hosted endpoint). |
| Terminal-as-MCP-*host* (FinceptTerminal's `mcp/` module: `McpManager`, `ToolDispatcher`, `ProviderAdapter` for OpenAI/Anthropic/Gemini) | The desktop app itself calls out to LLM providers and exposes ~40 internal tools | **Gap** | Vyapaar's `vyapaar-agent-mcp` is the *server* side (exposing Vyapaar as tools to an agent). A terminal-side multi-provider LLM host/dispatcher embedded in `vyapaar-ui` doesn't exist yet. |
| Tool discovery tiers (core tools + `*_catalog` + search/describe/call, to avoid context bloat) | Avoids dumping 443 tool schemas on every agent | **Gap** | `vyapaar-agent-mcp/tools.rs` is a flat list today (unverified exact shape, but no evidence of a catalog/discovery tier). Worth adopting if Vyapaar's own tool surface grows past ~30-40 tools. |
| Uniform result envelope (`result/v1`: `status`/`summary`/`data`/`blocks`/`warnings`/`error{code,hint}`) | Every tool, regardless of domain, answers the same shape | **Gap** | `vyapaar-runtime-api-rest` has per-endpoint response shapes (`orders.rs`, `portfolio.rs`, etc.) and an OpenAPI generator (`openapi.rs`), but no evidence of one shared envelope type. This is a cheap, high-leverage adoption: define once in `vyapaar-core` (it already owns wire contracts), reuse everywhere. |
| `$fincept` cross-tool data references (server resolves another tool call server-side instead of the agent round-tripping data) | Avoids agents shuttling huge payloads through their own context | **Gap** | No equivalent found. Relevant to `vyapaar-agent-mcp` once it exposes read-heavy tools (market data, portfolio) that other tools would want to compose. |
| Large-result paging (results >40KB stored server-side, paged via a `read_result` tool) | Keeps huge screens/backtests out of the agent's context | **Gap** | `vyapaar-runtime-api-rest` has `run_store.rs`/`report_store` concepts already (unverified exact names) for backtest runs, but no generic "any large tool result gets a ticket + pager" pattern for the MCP surface specifically. |
| Per-tool annotations (`readOnlyHint`/`destructiveHint`/`idempotentHint`) for client-side approval gating | Lets the calling agent/host decide what needs confirmation | **Gap** | No equivalent; directly relevant given `vyapaar-risk`'s pre-trade gate already embodies a "don't let this happen without a check" philosophy — this is the agent-facing analogue. |

---

## 2. "Terminal" stateful toolsets (18 toolsets, 443 tools)

| Fincept toolset | Covers | Vyapaar status | Mapped/closest module |
|---|---|---|---|
| `market` | quotes, candles, fundamentals, option chains, futures curves, corp actions, econ calendar | **With changes** | `vyapaar-market-core`, `vyapaar-market-feed`, `vyapaar-market-normalizer`, `vyapaar-market-finance` (India F&O grammar, calendar, costs). Vyapaar is India-only/broker-adapter-driven (angelone/dhan/fyers/upstox/zerodha); Fincept is global/68-country. Scope, not architecture, is the gap. |
| `backtest` | strategy backtests, sweeps, templates, validation, cost profiles, run history | **Direct** | `vyapaar-runtime-backtest` (`catalog.rs`, `engine.rs`, `events.rs`, `calendar.rs`) + `vyapaar-runtime-enhancer` (walk-forward, Bayesian/GA optimizers, Monte Carlo stress, overfitting guardrails). This is arguably *more* rigorous than Fincept's described backtest toolset. |
| `algo` | algorithm library, versions, baskets, paper deployments | **With changes** | `vyapaar-agent-genetic` (Odysseus synthesis), `vyapaar-runtime-strategy`. No explicit "basket" or versioned-algorithm-library concept found; paper deployment exists via `vyapaar-ledger` + exec router presumably, unverified. |
| `crypto` (76 tools, incl. DeFi) | crypto venues, derivatives, custody, compliance | **Gap** | No crypto adapter anywhere in `vyapaar-exec`/`vyapaar-market` (only Indian equity/F&O brokers). Explicitly out of current bounded-context map. |
| `data` | global econ/financial series, vendor fundamentals, adjusted prices | **With changes** | `vyapaar-data` repo exists (Python + DuckDB per `AGENTS.md`) but its current scope (point-in-time corp actions, splits, dividends) is narrower than Fincept's cross-provider econ series. |
| `filings` (SEC EDGAR, 13F, SEDAR+) | regulatory filings/insiders/funds | **Gap** | No filings ingestion anywhere; India's equivalent would be BSE/NSE/SEBI filings, not currently modeled. |
| `deals` (M&A, comps, private raises) | corporate finance data | **Gap** | Nothing comparable; out of scope for a trading platform's domain unless deliberately added as research data. |
| `portfolio` | valuation, performance, attribution, risk, scenarios, ledger, tax lots, benchmarks | **With changes** | `vyapaar-ledger-portfolio` ("pure portfolio valuation: positions, marks, FIFO tax lots, T+1 settlement") is the direct analogue, but attribution/scenario/benchmark analytics aren't evidenced there — likely live partly in `vyapaar-agent-analytics` instead (see §3). |
| `paper` | paper-trading account, orders/positions/trades, equity curves | **Direct** | `vyapaar-ledger` (OMS state machine) + `vyapaar-runtime-backtest` cover this; Vyapaar's live/paper duality is architecturally central (ADR-level "research-live parity" per `AGENTS.md` §5.3), arguably stronger than Fincept's bolt-on paper account. |
| `workspace` (watchlists, alerts, notes, notebooks, reports, custom indices) | user-facing organizational tools | **Gap** (platform), **Direct** (terminal) | Nothing in the Rust core, but `FinceptTerminal/src/screens` has `watchlist`, `dashboard` (canvas+widgets), `report_builder`, `notebooks` as a close UI analogue for `vyapaar-ui`. |
| `research` (ask Fincept's research model) | NL Q&A over Fincept's data | **With changes** | `vyapaar-agent-research` ("autonomous quantitative research loop: hypothesis generation, backtest pipeline, statistical verification") is more automated/closed-loop than a simple Q&A tool — different shape, same bounded context. |
| `agents` (server-side agent runs/schedules/memories) | manage agent lifecycles | **With changes** | `vyapaar-agent-core`, `vyapaar-agent-trader-loop`, `vyapaar-agent-replay` (cryptographic replayability per `AGENTS.md` §5.5) cover lifecycle/replay; scheduling across many agents as a platform feature is unverified. |
| `account` (profile, credits, usage) | SaaS billing/usage metering | **Gap** | Not applicable unless Vyapaar becomes a hosted multi-tenant product. |
| `analytics` (portfolio analytics, attribution, technicals, macro factors, regimes, option strategies, vol surfaces) | mixed grab-bag of analytics tools exposed at the toolset layer | **With changes** | Split across `vyapaar-agent-analytics` (trade/equity stats, DSR, PBO, tearsheet) and `vyapaar-market-indicators`. Macro factors, regime detection, vol surfaces are gaps (see §3). |
| `screener` | stock screens + run history | **Direct** | `vyapaar-market-indicators/screener.rs` and `vyapaar-runtime-api-rest/screener.rs` both exist — two screener surfaces already; worth checking they're not duplicating effort. |
| `quantlab` (experiments/trials, deflated Sharpe, signal/correlation checks, lineage) | research experiment tracking | **Direct** | Near-exact match to `vyapaar-agent-analytics` (`dsr.rs`, `holdout.rs`, `cointegration.rs`) + `vyapaar-agent-research` (`hypothesis.rs`, `manifest.rs`, `verification.rs`). Lineage/experiment-tracking-as-a-product-surface (vs. internal pipeline) may still be a gap. |
| `news` (feed/search, sentiment, AI summaries, monitors) | news & sentiment data | **Gap** (platform) / **Direct** (terminal) | No Rust crate; `FinceptTerminal/src/screens/news` + `services/news` cover this at the UI layer only, and are flagged by its own docs as carrying domain logic that should be in services. |
| `altdata` (geopolitical, maritime/AIS, shipping, sovereign curves) | alternative data | **Gap** (platform) / **Direct** (terminal) | Same split as `news` — `FinceptTerminal` has `geopolitics`, `maritime` screens/services; nothing in Vyapaar's Rust core. |

---

## 3. Analytics engines (17 stateless compute engines)

| Fincept engine | Core math | Vyapaar status | Mapped module |
|---|---|---|---|
| Fincept Stats (regression, ARIMA, VAR, unit-root/hypothesis tests, R-style formulas) | general statistics | **Gap** | No general statistical modeling layer; `vyapaar-agent-analytics` is finance-specific (DSR/PBO/cointegration), not a general stats toolkit. |
| Fincept Forecast (ML forecasting: LightGBM/XGBoost/CatBoost + conformal intervals, panel support) | ML time-series forecasting | **Gap** | `vyapaar-agent-genetic`/`vyapaar-runtime-enhancer` optimize *strategies*, not raw series forecasts. No forecasting engine. |
| Fincept Allocation (26 risk measures, risk parity, HRP/HERC/NCO, Black-Litterman, entropy pooling) | portfolio optimization | **Gap** | `vyapaar-ledger-portfolio` values positions; it doesn't optimize allocations. This is the single highest-leverage gap if "quantcepts" portfolio-construction features matter. |
| Fincept Portfolio Optimizer (mean-variance, CLA, HRP, semivariance/CVaR, discrete allocation) | overlaps Allocation, narrower | **Gap** | Same as above. |
| Fincept Quant (`quant_*`: series algebra, returns, realized/EWMA vol, Sharpe, basket backtests, SIR/SEIR) | general quant transforms | **With changes** | Pieces exist scattered: `vyapaar-market-indicators` (indicators), `vyapaar-agent-analytics` (returns/vol stats), `vyapaar-runtime-backtest` (basket backtests). No unified "quant transforms" library — this is the most direct candidate to lift into `vyapaar-core` or a new shared crate, per `AGENTS.md` §4.1's "consolidation over duplication" rule. |
| Fincept Volatility (GARCH family, VaR/ES, variance-ratio/cointegration tests) | volatility modeling | **Gap** | No GARCH or VaR/ES model found anywhere in the Rust crates. |
| Fincept Panel (fixed/random effects, Fama-MacBeth, IV/GMM, factor asset pricing) | panel econometrics | **Gap** | Nothing comparable; this is research-grade econometrics, likely lowest priority for a live-trading platform. |
| Fincept TS Forecast (ARIMA/ETS/Theta/TBATS, intermittent demand, panel) | statistical forecasting | **Gap** | Same gap as Fincept Forecast, different model family. |
| Fincept Technicals (201 indicators + 61 candlestick patterns) | technical analysis | **With changes** | `vyapaar-market-indicators` has ~17 indicators (SMA/EMA/RSI/MACD/Bollinger/ATR/ADX/Stochastic/Supertrend/VWAP/Williams %R/OBV/Donchian/CPR/RMA) — real but ~8% of Fincept's catalog. Same architecture (incremental, pure, WASM-portable per its own description) — this is a breadth gap, not a design gap. |
| Fincept Scanner (~4000 fields, 68 countries, filter DSL, formula screens) | screening | **With changes** | Two screener crates exist (see §2) but field/market breadth is far narrower (India-only). |
| Fincept Performance (CAGR/drawdown/Calmar/Sharpe/Sortino, deflated Sharpe, CSCV overfitting check) | performance reporting | **Direct** | `vyapaar-agent-analytics` (`tearsheet.rs`, `dsr.rs`, `pbo.rs`, `equity_stats.rs`) is a near 1:1 match, arguably Vyapaar's strongest overlap with any Fincept engine. |
| Fincept Change Points (PELT, binary seg, regime/trend/beta breaks) | change-point detection | **Gap** | No changepoint detection; `vyapaar-agent-genetic/regime.rs` exists but is for the genetic strategy synthesizer's regime *input*, not a general changepoint engine — worth checking if it could be extended rather than building new. |
| Fincept Regimes (HMM regime detection, transition matrices) | regime detection | **With changes** | Same `regime.rs` candidate as above — unverified whether it's HMM-based or simpler. |
| Fincept Copula (dependence/tail dependence, vine copulas, copula VaR) | copula modeling | **Gap** | Nothing comparable. |
| Fincept Multi-Period (multi-period policy optimization, market simulator, pre-trade checks) | trading policy optimization | **With changes** | `vyapaar-runtime-enhancer` + `vyapaar-risk` (pre-trade checks is literally `vyapaar-risk`'s entire job, just not "optimization-aware" the way Fincept's engine frames it) overlap conceptually but weren't designed as one engine. |
| Fincept Portfolio Lab (46 risk/return measures, factor lab, walk-forward+purged CV, hierarchical allocation) | portfolio research superset | **With changes** | `vyapaar-runtime-enhancer` already has walk-forward + overfitting guardrails; the factor-lab/hierarchical-allocation half is a gap. |
| Fincept Pricing (bonds, credit, yield curves, options Greeks, vol surfaces, swaps) | derivatives/fixed-income pricing | **Gap** | Nothing comparable; Vyapaar is equity/F&O execution-focused, not a derivatives pricing library. Given `vyapaar-market-finance` already encodes India F&O grammar, options *pricing* (not just contract grammar) is the natural next step if options strategies matter. |

---

## 4. Terminal UI/architecture patterns (FinceptTerminal → `vyapaar-ui`)

| FinceptTerminal pattern | What it is | Vyapaar status | Notes |
|---|---|---|---|
| Modular monolith, strict one-way layering (Presentation → Application → Data Plane → Adapters → Infra), enforced via `AGENTS.md`-style ADRs | architecture discipline | **Direct** | This is exactly `vyapaar-labs`' own DDD bounded-context approach (§2-4 of this repo's `AGENTS.md`). No change needed — if anything, Vyapaar's zero-I/O domain purity rule is *stricter* than FinceptTerminal's (which has no documented decimal/float policy — see below). |
| `DataHub` — in-process pub/sub, topic-keyed (`domain:subdomain:id[:modifier]`), one-fetch/many-subscribers, TTL cache, last-known-good fallback | cross-context data plane | **Gap** (as a named pattern) | Vyapaar's event pipeline (`AGENTS.md` §2.2: MarketEvent → SignalEvent → OrderEvent → FillEvent → LedgerEvent) is unidirectional and typed, which DataHub's topic system is not (it's untyped pub/sub by string key). Vyapaar's approach is arguably more rigorous; no need to adopt DataHub's pattern, but the "last-known-good on producer failure" resilience idea is worth lifting into `vyapaar-runtime-feed`. |
| `BrokerEnumMap<T>` — data-table mapping of broker wire-enums to canonical enums, replacing per-broker if-chains | anti-corruption layer implementation | **Direct concept, verify implementation** | This *is* the ACL pattern `AGENTS.md` §3.1 already mandates ("Incoming raw WebSocket payloads... must be parsed inside adapters and translated immediately to canonical Tick/Bar models"). Worth checking whether Vyapaar's `vyapaar-market-{broker}` crates use a similar table-driven mapping or still have if-chains — FinceptTerminal's own docs admit this was a *retrofit* (14/16 brokers migrated), i.e. it wasn't done this way from day one either. |
| No documented decimal/float policy anywhere in README/ARCHITECTURE/ADRs | price/money representation | **Direct (Vyapaar is strictly better here)** | Vyapaar's zero-floats policy (`AGENTS.md` §2.3, `rust_decimal::Decimal` everywhere) is a real, enforced advantage. Nothing to change; worth noting as a selling point if any FinceptTerminal-derived code is ever ported in — all numeric ports need a decimal audit, not a straight copy. |
| Embedded Python via subprocess bridge (`QProcess`, JSON over stdout, cold-start 0.5-1.5s, concurrency-capped at 3) | running Python quant models from a native app | **With changes** | Vyapaar already has a *better* answer architecturally: `vyapaar-ffi` (PyO3, Arrow zero-copy, `py.allow_threads`) per `AGENTS.md` §6.2 — in-process, no subprocess cold-start, no JSON marshalling tax. If any FinceptTerminal-style "run a Python quant script from the UI" feature is wanted in `vyapaar-ui`, route it through `vyapaar-ffi`, not a subprocess bridge. |
| QCoro async migration still in progress (callbacks today, coroutines targeted, blocked on 3-platform CI) | async model | **Not applicable** | Vyapaar's runtime is Tokio-based from the start (`AGENTS.md` top-level table); no analogous migration debt. |
| Thin test coverage (4 unit test files vs. ~1,900 source files) | quality signal | **Direct (Vyapaar is strictly better)** | `AGENTS.md` §3.2 mandates TDD + parallel `tests/` dirs as a hard rule; this is called out here only as a cautionary data point — don't port FinceptTerminal UI *behavior* assumptions without writing Vyapaar-side tests first, since the source material itself is lightly tested. |
| 54 screens / ~50 services across Markets, News, Economics, Geopolitics, Trading, Portfolio, Crypto, Derivatives, Predictions, Agents, AI Chat, Workflow, Identity bounded contexts | UI feature surface | **With changes / Gap**, screen by screen | `vyapaar-ui` has `vyapaar-ui-charts`, `vyapaar-ui-app`, `vyapaar-ui-core`, `vyapaar-cli`, `vyapaar-tui` — a UI shell exists, but the feature-screen inventory (watchlist, screener UI, backtest UI, portfolio UI, algo trading UI, node-editor/workflow builder, AI chat/agent workbench) is largely unbuilt. This is the single largest surface-area gap in the whole comparison, but also the lowest-risk one to leave for last — it's presentation, not domain logic. |

---

## 5. Headline takeaways (not recommendations — see integration plan discussion for those)

1. **Vyapaar's execution/risk/ledger/backtest-validation core is already ahead of or at parity with Fincept's equivalents** (§2 `backtest`/`paper`/`quantlab`, §3 Performance engine). The zero-float and DDD discipline are real, verified advantages — nothing there needs to change to "catch up."
2. **The biggest honest gaps are breadth, not depth**: technical indicators (17 vs 201), screener fields/markets (India-only vs 68 countries/4000 fields), and whole missing analytics families (volatility/GARCH, regimes, copulas, change-points, derivatives pricing, portfolio allocation optimization, general forecasting).
3. **The MCP-surface conventions are the cheapest, highest-leverage adoption**: Vyapaar already has `vyapaar-agent-mcp`; a shared result envelope, tool-discovery tiers, and cross-tool data references are additive patterns on top of existing code, not new bounded contexts.
4. **FinceptTerminal's UI feature inventory, not its backend architecture, is the real "quantcepts" reference** for `vyapaar-ui` — its architecture (DataHub, BrokerEnumMap, modular monolith) is a *less* rigorous version of what Vyapaar's `AGENTS.md` already mandates, so there's little to borrow architecturally; the 54-screen feature list is the useful artifact.
5. **Unresolved**: whether "Quantcepts" (as the user's term) means (a) FinceptTerminal's quant-adjacent screens/services, (b) the Fincept MCP analytics engines, or (c) the separate quantcept.io product not covered here. The mapping above treats (a) and (b) as the evidence base; (c) needs its own pass if it matters.
