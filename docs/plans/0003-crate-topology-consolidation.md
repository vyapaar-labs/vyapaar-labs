# 0003 — Crate Topology Consolidation: remove stubs, dedupe, and pin the facade convention

**Status**: Proposed
**Target Scope**: `vyapaar-market`, `vyapaar-exec`, `vyapaar-runtime` (crate deletion / facade
  convention); all 9 Rust workspaces verify clean builds after.
**Gaps covered**: [`docs/gaps/0001`](../gaps/0001-market-broker-feed-stubs.md) through
  [`docs/gaps/0008`](../gaps/0008-legacy-alias-deps.md).
**Design basis**: [`docs/design/0001-crate-topology-audit-and-target.md`](../design/0001-crate-topology-audit-and-target.md).

---

## 0. Executive Summary & Objective

The repo-per-bounded-context layout is correct and stays. The intra-repo crate inventory is not:
**12 of 72 Rust crates are empty stubs, re-export shims, or exact duplicates** (17% overhead), the
real market-feed trait lives in `vyapaar-market-core` while an empty `vyapaar-market-feed` crate
claims that name, and `vyapaar-runtime` carries a duplicate `vyapaar-indicators` plus legacy honba
aliases. This plan removes the stubs (tracked as open gaps so the *capability* is not lost),
dedupes the indicator/feed shims, and pins one facade-crate convention. Target: **72 → ~60 crates**
with zero loss of implemented functionality and zero domain-logic changes.

### Phases at a glance

| Phase | Outcome | Crates removed | Gap(s) |
| :--- | :--- | :---: | :--- |
| 1 — Market stub removal | `vyapaar-market` 14 → 7 | `feed`, `loaders`, `zerodha`, `upstox`, `fyers`, `angelone`, `dhan` | 0001, 0002 |
| 2 — Runtime dedupe + shim | `vyapaar-runtime` 14 → 10 | `indicators`, `market`, `test-utils`; `feed` absorbed into `api-rest` | 0003, 0004, 0005 |
| 3 — Exec angelone decision | `vyapaar-exec` 8 → 7 or 8 | `angelone` (implement or remove) | 0006 |
| 4 — Facade convention + alias cleanup | convention pinned; `runtime` aliases gone | 0 (re-exports only) | 0007, 0008 |
| 5 — Full-workspace verification | all 9 Rust repos green | — | — |

---

## 1. Context & Gaps Covered

- **GAP-0001** (`vyapaar-market` broker WS crates): 5 empty broker crates (zerodha, upstox, fyers,
  angelone, dhan). Verified: nothing imports them.
- **GAP-0002** (`vyapaar-market-feed`/`loaders`): empty; feed trait is in `market-core`, lakehouse
  in `market-store`.
- **GAP-0003** (`vyapaar-runtime/vyapaar-indicators`): 1-line duplicate of the real
  `vyapaar-market-indicators`; nothing imports it.
- **GAP-0004** (`vyapaar-runtime-feed`): 30-line re-export shim over `vyapaar-market-store`,
  consumed by `vyapaar-runtime-api-rest` (which already depends on `market-store` directly).
- **GAP-0005** (`vyapaar-runtime-market`, `vyapaar-runtime-test-utils`): empty stubs, legacy
  `honba` names; the `api-rest` dependency on `runtime-market` is declared-but-unused.
- **GAP-0006** (`vyapaar-exec-angelone`): 9-line near-empty stub vs. real zerodha/upstox siblings.
- **GAP-0007** (facade convention): ledger/agent have repo-named facades; market/exec/runtime/
  ffi/ui do not.
- **GAP-0008** (legacy aliases): unused `vyapaar-api`/`vyapaar-api-rest`/`vyapaar-backtest`/
  `vyapaar-actors` entries in `vyapaar-runtime` `workspace.dependencies`.

## 2. Component Specifications & Phases

### Phase 1 — `vyapaar-market` stub removal (gaps 0001, 0002)

- Delete the 7 stub crate directories and their `members` + `workspace.dependencies` entries in
  `vyapaar-market/Cargo.toml`.
- Do **not** create replacement empty crates. Real broker feeds, when implemented, are re-added
  as real crates (gap 0001 stays open as the feature tracker).
- Keep `vyapaar-market-core` as the single home of `MarketDataFeed` and `vyapaar-market-store` as
  the single home of the lakehouse.
- Acceptance: `cd vyapaar-market && cargo check --workspace --profile prod && make test` green;
  workspace has 7 members.

### Phase 2 — `vyapaar-runtime` dedupe + shim absorb (gaps 0003, 0004, 0005)

- Delete `vyapaar-runtime/crates/vyapaar-indicators`, `vyapaar-runtime-market`,
  `vyapaar-runtime-test-utils` and their workspace entries.
- Absorb `vyapaar-runtime-feed`: move the `pub use vyapaar_market_store::*` re-exports into a
  `market_feed` module of `vyapaar-runtime-api-rest` (the only real consumer), update the ~28
  import sites from `vyapaar_runtime_feed::X` to the new path, delete the shim crate.
  (Alternative: retain as a declared compatibility facade per the convention pinned in Phase 4.)
- Remove the dangling `vyapaar-runtime-market.workspace = true` line from
  `vyapaar-runtime-api-rest/Cargo.toml`.
- Acceptance: `cd vyapaar-runtime && cargo check --workspace --profile prod && make test` green;
  grep shows no `vyapaar_runtime_feed::` / `vyapaar_indicators` / `vyapaar_runtime_market` /
  `vyapaar_runtime_test_utils` imports remaining.

### Phase 3 — `vyapaar-exec-angelone` decision (gap 0006)

- Decide: implement the Angel One execution ACL (real broker logic, `tests/`, clippy-clean) **or**
  remove the crate from the workspace like Phase 1. Implementation is preferred if Angel One
  execution is on the near-term roadmap; otherwise remove and keep gap 0006 open as the tracker.
- Acceptance: `cd vyapaar-exec && cargo check --workspace --profile prod && make test` green.

### Phase 4 — Facade convention + alias cleanup (gaps 0007, 0008)

- **Pin the convention (ADR in this repo)**: every multi-crate Rust workspace exposes a repo-named
  facade crate containing only re-exports; member crates remain `-internal` or conventionally
  named. `vyapaar-ledger`/`vyapaar-agent` already conform; add facade crates for
  `vyapaar-market`, `vyapaar-exec`, `vyapaar-runtime`, `vyapaar-ffi`, `vyapaar-ui` (each a thin
  `pub use` aggregator). If the reverse decision is ever taken, retire the existing facades — but
  pin exactly one.
- Remove the 4 legacy aliases from `vyapaar-runtime/Cargo.toml` `[workspace.dependencies]`.
- Update `docs/design/architecture.md` + `docs/design/0001-*.md` with the pinned convention.
- Acceptance: one documented convention; `vyapaar-runtime` has no legacy alias entries.

### Phase 5 — Full-workspace verification

- For every Rust repo: `make prod` (end-of-turn invariant), `cargo clippy --all-targets --
  -D warnings`, `cargo test --workspace --profile prod`.
- Update each touched repo's `docs/{plans,gaps}/README.md` index and this plan's status when
  complete.

## 3. Out of Scope / Non-Goals

- **No Python changes**: `vyapaar-adapters` broker SDKs are untouched (dev/research-only per
  `vyapaar-adapters/docs/plans/0001`).
- **No domain-logic refactors**: zero-I/O, zero-floats, WASM portability, and OMS/portfolio/risk
  behavior are unchanged.
- **No new feature work**: this plan only removes/absorbs stubs and pins the facade convention.
- **Repo layout unchanged**: each bounded context stays its own Git submodule.

## 4. Risks & Mitigations

| Risk | Mitigation |
| :--- | :--- |
| A removed stub was secretly depended upon | Pre-verified with grep for every stub (all clean except `runtime-feed`, handled in Phase 2); CI gate per phase |
| Import churn in `vyapaar-runtime-api-rest` (~28 sites) | Mechanical sed/import rename; `cargo check` catches stragglers; Phase 2 lands alone |
| Facade convention flip-flops later | Pin via ADR in this repo and reference it from `docs/design/architecture.md` |
| Broker-feature loss by deleting stubs | Gaps 0001/0006 remain open as feature trackers; re-add only with real implementations |
| `workspace.dependencies` path entries left dangling | Every removal commit also prunes the owning workspace's `Cargo.toml` entries atomically |

## 5. Reference Inputs

- `.agents/AGENTS.md` §2.1 (bounded-context taxonomy), §3.2 (tests in `tests/`), §11 (prod profile).
- `.agents/rules/gap-tracking.md` (filing/lifecycle), `.agents/rules/handoff-hygiene.md`.
- `docs/ddd-conflict.md` (migration resolutions this plan completes — e.g. Conflict #4 feed/store,
  Conflict #6 broker ACLs).
- `docs/design/architecture.md` and `docs/design/0001-crate-topology-audit-and-target.md`.
