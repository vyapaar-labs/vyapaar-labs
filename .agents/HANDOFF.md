# HANDOFF — vyapaar-labs Bottom-Up Migration Batch (Tier 0 → Tier 6)

**Status: TIER 4 GREEN — `vyapaar-ffi` migrated & implemented from scratch (codegen + PyO3 ABI3 `vyapaar._vyapaar` + Arrow capsule bridge + `python/vyapaar` SDK). `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test --workspace` (26/26) all PASS; `make all` (incl. maturin wheel + 36 pytest tests) PASS; zero `#[cfg(test)]` in `src/`. Next: Tier 5A `vyapaar-ui`.**
Date: 2026-11-05 · Workspace: `/project1/vyapaar-labs` · Source: `/home/pmallapp/Devel/Finance/honba-workspace` (not mounted on this host — Tiers implemented from design docs + sibling submodules)
Playbook: `docs/migration-guide.md` (canonical orchestration)

## Latest Batch — Fincept/Quantcept gap-closure, Layers 0, 1, 2, 2b, 3 (bottoms-up build order)

Playbook: `docs/future-work-bottoms-up-build-order.md` — Layers 0, 1a, 1b, 1c, 2, 2b, and 3 all GREEN. Each subrepo (vyapaar-core, vyapaar-risk, vyapaar-ledger, vyapaar-market, vyapaar-exec, vyapaar-adapters, vyapaar-ffi, vyapaar-strategies) is an independent git repo with its own commit. `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test` PASS in every touched Rust repo; `ruff check`/`ruff format --check`/`mypy`/`pytest` PASS in `vyapaar-strategies`. Zero `#[cfg(test)]`/`#[test]` in `src/`; zero floats crossing domain boundaries.

| Layer | Doc | Commit | Status |
| :---: | :--- | :--- | :---: |
| 0 | `vyapaar-core/0001` quant primitives (`quant.rs`: `QuantSeries`, `QuantError`, simple/log returns, realized/EWMA vol, rolling mean/stdev, Sharpe, max drawdown, correlation, beta; golden + proptest in `tests/quant_tests.rs` / `tests/quant_proptest.rs`) | `vyapaar-core` 9ce4880 | ✅ |
| 1a | `vyapaar-ledger/0001` new `vyapaar-ledger-allocation` crate, Phase 1 (MeanVariance + RiskParity, `WeightBounds`, `PortfolioState::from_portfolio` read-adapter, `optimize()`, `TargetWeights` with custom serde; pure-Decimal Gauss-Jordan + damped risk-parity fixed point; 17 tests) | `vyapaar-ledger` b35a314 | ✅ |
| 1b | `vyapaar-risk/0001` `ToolRiskHint` + `risk_classification(&Decision)` (DecisionKind doesn't exist in core → classify the closed `Decision` enum directly; exhaustive tests) | `vyapaar-risk` 5b00cda | ✅ |
| 1c | `vyapaar-market/0001` Phase 1: 18 indicators (ichimoku, keltner_channels, parabolic_sar, cci, mfi, roc, trix, aroon, chaikin_money_flow, cmo, ultimate_oscillator, elder_ray, kst, vortex, fisher_transform, pivot_points, hull_ma, mass_index) + Phase 2: new `vyapaar-market-pricing` crate (Black-Scholes price/Greeks/IV, f64-internal/Decimal-boundary documented) | `vyapaar-market` ddb5c3f + 1983512 | ✅ |
| 2 | `vyapaar-exec/0001` Phase 1 + `vyapaar-market/0001` Phase 3, run jointly — **broker wire-mapping verification/refactor**: exec-side confirmed ad-hoc match chains → new table-driven `BrokerEnumMap<T>` in `vyapaar-exec-core::wiring` (+ `OrderTypeKind` discriminant), per-broker `mapping` tables in `vyapaar-exec-zerodha`/`-upstox` (status/side/exchange/order-type, REST + ticker + postback + WS feed paths), parallel `tests/wire_mapping_tests.rs` + `tests/wiring_tests.rs`; market-side verified to have no wire code yet (4 placeholder crates + dhan stub) → documented as forward contract. Phase 2 crypto scope decision resolved **NO-GO** (recorded in the plan; Phase 3 skipped). | `vyapaar-exec` 2675c07 + ed3a6b3, `vyapaar-exec` (crypto no-go) | ✅ |
| 2b | `vyapaar-adapters/0001` — Python/Rust adapter boundary **RESOLVED as Resolution 1** (dev/research convenience layer) + tracked broker coverage table + standing rules (Python = non-production/dev-research; Kotak/IIFL/Fyers-exec legitimately Python-only until Rust ports; new `vyapaar-market-*` crates must use the Layer-2 `BrokerEnumMap<T>` pattern). `vyapaar-ffi/0001` — Python-first quant engine bridge policy **ADOPTED** as standing policy, claims verified against `vyapaar-ffi-py` (Arrow `arrow_array_stream` PyCapsule bridge + `py.detach` GIL release). No code changed in either repo (decision/policy gates only). | `vyapaar-adapters` (doc), `vyapaar-ffi` (doc) | ✅ |
| 3 | `vyapaar-strategies/0001` — **all 3 phases**: `StrategyManifest` (semver, module:Class, params, target instruments, absolute/weight capital allocation; validates params against the strategy class + instantiates) + `BasketManifest` (member weight-XOR-allocation refs, combined-capital budget ≤ cap, Phase-1 `RiskBudget` caps) + `PromotionStatus` promotion workflow (one stage forward: draft→backtested→paper→live, status-prefixed evidence refs). POC sidecars `manifests/strategies/{turtle_breakout,twap_slicer}.toml` + `manifests/baskets/turtle_twap_basket.toml`; Zone 4 JSON schemas + `tools/validate_manifests.py`; 42 tests in `tests/manifests/`. Gate: pytest 119/119, ruff, mypy PASS. Runtime consumption cross-ref only (no `vyapaar-runtime` changes). | `vyapaar-strategies` 207a70c | ✅ |

Key decisions: vyapaar-core enables `rust_decimal` `maths` feature (pure-Decimal `sqrt`/`ln`, no floats). Layer 2 refactor was Red-Green on new tests with the existing conformance/rest/ticker/postback suites untouched and green; `BrokerEnumMap::get` is ASCII case-insensitive (brokers emit both `COMPLETE` and `complete`), canonical→wire payload building left as exhaustive matches (no unmapped fallback, out of the doc's scope). **Crypto execution is NO-GO** — no `vyapaar-exec-{exchange}` crate, no crypto adapter anywhere; the decision is recorded and revisitable only via fresh scope review. Python adapters are dev/research-only for brokers with a Rust production path. `vyapaar-risk` commit does not bump any risk-gate behavior.

## Latest Batch — Tier 4 (`vyapaar-ffi`, committed to its submodule `vyapaar-ffi`)
| Slice | Milestone | State |
| :---: | :--- | :---: |
| T4 | **`vyapaar-ffi-codegen`**: deterministic `schema/domain_schema.json` (draft 2020-12, 21 wire types), `schema/openapi.json` (OpenAPI 3.1), `python/vyapaar/_vyapaar.pyi` contract; CLI `vyapaar-codegen`; idempotent. | ✅ |
| T4 | **`vyapaar-ffi-py`**: value classes (`Price`/`Quantity`/`Money`/`InstrumentId`/`Exchange`/`Currency`/`OrderSide`/`TimeInForce`/`OrderStatus`), market (`Bar`/`Tick`/`DepthLevel`), orders (`OrderRequest`/`OrderAck`/`FillReport`/`OrderEvent`), `Decision.from_json`; exact-decimal-only boundary. | ✅ |
| T4 | **Risk gate**: `RiskEngine` wrapping `vyapaar_risk` — every Python-submitted order/decision passes the synchronous non-bypassable gate; raises `RiskRefused` with `rule=` prefix; `StrategyRunner` gates, simulates fills, dispatches `on_bar`/`on_tick`/`on_order_event` with GIL held only at the callback boundary, `py.detach` around Rust-side batch work. | ✅ |
| T4 | **Arrow zero-copy bridge**: `bars_to_stream`/`ticks_to_stream` export Decimal128(38,8)/Timestamp(us,UTC) `RecordBatch` streams as `arrow_array_stream` PyCapsules (C Data Interface), consumed by pyarrow (`RecordBatchReader._import_from_c_capsule`) with zero-copy semantics. | ✅ |
| T4 | **Python SDK**: `python/vyapaar` (`Strategy`/`Parameter`/`run`/`BacktestResult`, Decimal SMA/EMA/RSI, sizing, IST session windows, `data.bars_to_arrow`/`bars_to_polars`, `cli`), `py.typed` + `__init__.pyi`; maturin wheel `vyapaar-0.1.0-cp310-abi3`; 36 pytest tests green. | ✅ |
| T4 | **Infra**: Makefile `bootstrap-python`/`codegen`/`py-build`/`py-test`/`all`; GitHub Actions CI (Rust gate + maturin/pytest); `[profile.{dev,test,dbg,release,prod}]`; README/roadmap/HANDOFF updated. | ✅ |

## Prior Tiers

## Phase / Slice Status
| Slice | Milestone | State |
| :---: | :--- | :---: |
| 0 | **Superproject baseline**: git-initialized `vyapaar-labs` superproject (`.gitmodules` sub-repos are plain dirs until their own tiers migrate). Baseline commit of pre-migration skeleton. | ✅ |
| 0 | **Pre-flight hygiene**: `.agents/AGENTS.md` vocabulary — Rust-Core subgraph references now `vyapaar-core/ledger/risk/market/exec/runtime`, Python plane now `vyapaar SDK`; zero `honba*`/`kokoro`/`tamashii` strings remain. | ✅ |
| 0 | **Pre-flight hygiene**: standardized repo-root `Makefile` (`prod`, `release`, `dev`, `check`, `test`, `fmt`, `clippy`, `clean`, plus `debug`/`check-dev` extras) installed in `vyapaar-{core,risk,ledger,market,exec,runtime,brain,ffi,ui}`. | ✅ |
| T0 | **Tier 0 `vyapaar-core`**: port 15 honba-core modules verbatim with honba→vyapaar doc references; NEW `src/ids.rs` (`ClientOrderId`, `AlgoId`, `AccountId`, `TransactionId` promoted from the Domain Heart repository layer with `JsonSchema`); `Exchange::{Nfo,Cds}` unified; `Price::try_new`/`Quantity::try_new` + validated serde visitors rejecting negative wire values; deterministic `OrderRequest::with_id`; `CanonicalPositionSizer` intentionally NOT ported (concrete algorithm leaves the Shared Kernel per master-guide anti-pattern fix); schema/ copied with `honba`→`vyapaar` string pass; tests ported + placeholder `tests/unit_tests.rs` deleted. | ✅ |

## Final Gate Report (from `vyapaar-core/` crate root)
```
1  cargo fmt --check                                  PASS
2  cargo clippy --all-targets -- -D warnings          PASS
3  cargo test                                         PASS (46 tests, 0 failed across 4 suites: 34 core, 6 golden, 4 proptest, 2 schema-compat)
4  grep '#\[cfg(test)\]'/#'e#\[test\]' src/            PASS (0 matches — Parallel Test Directory Rule)
5  grep tokio/std::fs/std::net/Utc::now/Instant src/  PASS (0 matches — Zero-I/O & temporal determinism)
6  grep f32/f64 src/                                  PASS (0 matches — Zero-Floats)
```

## Decisions & Discoveries
- **Git topology**: `vyapaar-labs` is the git superproject (init'd on `main`); `.gitmodules` declares the 15 intended sub-repos but none have their own `.git` yet. Per-tier commits land on the superproject; sub-module extraction is a later concern, not in the Tier 0 scope.
- **Kernel slimming**: tier-0 ports `screener.rs`/`portfolio.rs` as wire contracts and the `ports.rs` trait set, per the detailed tier-0 playbook file map — but the concrete `CanonicalPositionSizer` is dropped from the kernel (master-guide antipattern §1.1); the object-safe `PositionSizer` port remains and the port test uses a local adapter instead.
- **Serde hardening**: `Price`/`Quantity` drop the derive-based `#[serde(transparent)]` in favor of manual `Serialize` (string form) + validating `Deserialize` visitors, so negative decimals can never enter the domain from JSON wire payloads; the `#[serde(transparent)]` attribute is kept so `schemars` emits the same transparent schema as the frozen `schema/domain/domain_schema.json` snapshot.
- **rust_decimal 1.43**: `is_zero()`, `is_sign_negative()` are `const fn`, so `Price::new`/`Quantity::new` remain `const` while gaining `debug_assert!` guards; `try_new` enforces the invariant unconditionally.

## Immediate Next Step
1. Next in the bottoms-up build order is **Layer 4** (two independent tracks):
   - 4A: `vyapaar-agent/0003` remaining Fincept analytics engines — Phase 1 `vyapaar-agent-forecast` wants Layer 0 return/vol primitives; Phase 3 `vyapaar-agent-panel` may prototype in Python first (Layer 2b `vyapaar-ffi` policy settled).
   - 4B: `vyapaar-agent/0004` free-tier LLM backend — fully independent of 4A, can run in parallel; internal order Phase 1→2→3→4 (local SLM last).
2. Layer 5 (`vyapaar-ui/0005`) stays deliberately last.
3. Layer 3's `BasketManifest` consumption lands in `vyapaar-runtime-backtest` (catalog.rs/engine.rs) as a separate future slice, per the plan's scope note.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- `SchemaVersion` stays `8`; schema snapshots are copied + string-replaced, never regenerated in Tier 0.
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
