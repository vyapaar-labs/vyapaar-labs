# Gaps Index — `vyapaar-labs` (root)

Root-level gaps tracked per `.agents/rules/gap-tracking.md`. Each gap documents an individual
stub, duplicate, or missing feature at the workspace level. Gaps whose root cause lives in a
provider submodule are filed here for cross-repo visibility and cite the provider repo; the
provider repo's own `docs/gaps/README.md` is the implementation tracker.

## Open Gaps

| # | Title | Provider Repo / Scope | Filed |
|---|-------|-----------------------|-------|
| [0001](0001-market-broker-feed-stubs.md) | `vyapaar-market` broker WS feed crates (`zerodha`, `upstox`, `fyers`, `angelone`, `dhan`) are empty stubs | `vyapaar-market` | 2026-11-12 |
| [0002](0002-market-feed-loaders-stubs.md) | `vyapaar-market-feed` and `vyapaar-market-loaders` are empty stubs; the real `MarketDataFeed` trait lives in `vyapaar-market-core` | `vyapaar-market` | 2026-11-12 |
| [0003](0003-runtime-indicators-duplicate.md) | `vyapaar-runtime/vyapaar-indicators` is an exact duplicate of the real `vyapaar-market-indicators` and nothing imports it | `vyapaar-runtime` | 2026-11-12 |
| [0004](0004-runtime-feed-shim.md) | `vyapaar-runtime/vyapaar-runtime-feed` is a 30-line re-export shim over `vyapaar-market-store` | `vyapaar-runtime` | 2026-11-12 |
| [0005](0005-runtime-stub-crates.md) | `vyapaar-runtime-market` and `vyapaar-runtime-test-utils` are empty stubs (legacy `honba` names) | `vyapaar-runtime` | 2026-11-12 |
| [0006](0006-exec-angelone-stub.md) | `vyapaar-exec-angelone` is a near-empty stub (9 lines, no broker logic) | `vyapaar-exec` | 2026-11-12 |
| [0007](0007-facade-crate-convention.md) | Facade-crate convention is inconsistent across Rust repos (ledger/agent have facades; market/exec/runtime/ffi/ui do not) | all Rust workspaces | 2026-11-12 |
| [0008](0008-legacy-alias-deps.md) | `vyapaar-runtime` `workspace.dependencies` still carries unused legacy honba aliases (`vyapaar-api`, `vyapaar-api-rest`, `vyapaar-backtest`, `vyapaar-actors`) | `vyapaar-runtime` | 2026-11-12 |

## Closed Gaps

| # | Title | Closed In |
|---|-------|-----------|
| — | *(none yet)* | — |

## Related

- [`docs/plans/0003-crate-topology-consolidation.md`](../plans/0003-crate-topology-consolidation.md)
  — the phased plan that executes these gaps.
- [`docs/design/0001-crate-topology-audit-and-target.md`](../design/0001-crate-topology-audit-and-target.md)
  — full audit and target arrangement.
