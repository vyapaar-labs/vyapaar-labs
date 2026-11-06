# HANDOFF — vyapaar-labs

**Status**: Bottoms-up Fincept/Quantcept gap-closing build order
(`docs/future-work-bottoms-up-build-order.md`) — Layers 0, 1, 2, 2b, 3 GREEN. **Next: Layer 4**
(4A `vyapaar-agent/0003` and/or 4B `vyapaar-agent/0004`, independent, can run in parallel).
Date: 2026-11-06 · Workspace: `/home/pmallapp/Devel/Finance/vyapaar-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md` (execution order, by crate dependency
depth). The repo-migration (`honba-*` → `vyapaar-*`, Tier 0–6) that used to be this file's whole
subject is complete and long superseded — see "Prior work" below.

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

## Prior work (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Tier 0–6 repo migration** (`honba-*` → `vyapaar-*` submodules, incl. Tier 4 `vyapaar-ffi`'s
  codegen/PyO3/Arrow bridge/Python SDK): complete. Full per-tier detail (gate reports, slice
  tables, Tier-0-specific design notes) lived here until 2026-11-06; trimmed now that it's long
  superseded by Tiers 5–6 and this file's current "Latest Batch" above. See commits
  `feat(tier-0)` through `feat(tier-6)` in this repo's git log for the full record; the migration
  guide that used to be this file's "Playbook" pointer was retired in `4b5d9f9`.

## Immediate Next Step
1. Next in the bottoms-up build order is **Layer 4** (two independent tracks):
   - 4A: `vyapaar-agent/0003` remaining Fincept analytics engines — Phase 1 `vyapaar-agent-forecast` wants Layer 0 return/vol primitives; Phase 3 `vyapaar-agent-panel` may prototype in Python first (Layer 2b `vyapaar-ffi` policy settled).
   - 4B: `vyapaar-agent/0004` free-tier LLM backend — fully independent of 4A, can run in parallel; internal order Phase 1→2→3→4 (local SLM last).
2. Layer 5 (`vyapaar-ui/0005`) stays deliberately last.
3. Layer 3's `BasketManifest` consumption lands in `vyapaar-runtime-backtest` (catalog.rs/engine.rs) as a separate future slice, per the plan's scope note.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
- `.agents/rules/subagent-discipline.md`, `.agents/rules/no-recon.md`, `.agents/rules/gap-tracking.md`, `.agents/rules/handoff-hygiene.md` are binding workspace-wide — see `AGENTS.md` §8–§10.
