# 0004 — `vyapaar-runtime/vyapaar-runtime-feed` is a re-export shim over `vyapaar-market-store`

**Status**: open

**Provider repo**: `vyapaar-runtime`

## What's stubbed or hardcoded

`vyapaar-runtime/crates/vyapaar-runtime-feed/src/lib.rs` (30 lines) is a pure re-export shim:
it does `pub use vyapaar_market_store::{...}` for the Parquet lakehouse types (`Lakehouse`,
`TickRecorder`, `Dataset`, `ParquetTickStore`, `ReportWriter`, etc.), plus re-export modules
`ports`, `import`, and `wire`.

It is consumed by `vyapaar-runtime-api-rest` (and declared in `vyapaar-runtime-strategy`'s
workspace deps), which **also** already depends directly on `vyapaar-market-store`.

## Why

During the `honba-*` → `vyapaar-*` migration the old `vyapaar_runtime_feed` import path was kept
alive so that `vyapaar-runtime-api-rest` and its ~28 test/`src` files would not need an import
rename in the same change that moved the lakehouse into `vyapaar-market-store`. The shim has
outlived that purpose.

## How to close it

Two options (plan 0003 Phase 2 decides; either closes this gap):

- **Option A (absorb)** — move the `pub use vyapaar_market_store::*` re-exports into a small
  `market_feed` module inside `vyapaar-runtime-api-rest` (or the crate that still needs the old
  path), update imports from `vyapaar_runtime_feed::X` to the new path, delete the shim crate and
  its `members`/`workspace.dependencies` entry.
- **Option B (keep as facade)** — document `vyapaar-runtime-feed` as an intentional facade crate
  (part of the facade convention from gap 0007) and leave it as-is. This closes the gap in the
  sense that it is no longer an *accidental* shim — it is a declared compatibility facade.

## Verification

`cd vyapaar-runtime && cargo check --workspace --profile prod && make test`; for Option A, grep
confirms no `vyapaar_runtime_feed::` imports remain outside the deleted crate.
