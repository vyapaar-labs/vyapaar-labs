# 0003 — `vyapaar-runtime/vyapaar-indicators` is an exact duplicate of `vyapaar-market-indicators`

**Status**: open

**Provider repo**: `vyapaar-runtime`

## What's stubbed or hardcoded

`vyapaar-runtime/crates/vyapaar-indicators/src/lib.rs` is a single comment line:
`// Stub crate: vyapaar-indicators`. It is registered as a member of the `vyapaar-runtime`
workspace, and `vyapaar-runtime/workspace.dependencies` maps `vyapaar-indicators` to it.

Meanwhile the real indicator engine is `vyapaar-market/crates/vyapaar-market-indicators`
(4,635 lines of `src`, real indicators). Nothing in any workspace imports
`vyapaar_indicators` in code (verified: `grep -rn "vyapaar_indicators" --include=*.rs` returns
nothing outside the stub's own directory).

## Why

A legacy `honba-ya-indicators` / `honba-me-indicators` naming collision: the runtime workspace was
scaffolded with a stub of the old name while the market workspace received the real ported crate.
The stub was never removed.

## How to close it

1. Remove `vyapaar-runtime/crates/vyapaar-indicators` directory and its `members` +
   `workspace.dependencies` entry in `vyapaar-runtime/Cargo.toml`.
2. Confirm no crate in `vyapaar-runtime` or elsewhere depends on `vyapaar-indicators`
   (verified: only the stub's own `Cargo.toml` listed it; `vyapaar-runtime-api-rest`'s
   `Cargo.toml` references it only via the workspace alias).
3. Keep `vyapaar-market-indicators` as the single canonical indicator crate.
4. Verify: `cd vyapaar-runtime && cargo check --workspace --profile prod` and `make test`.

## Verification

`cargo check --workspace --profile prod` passes without the stub; `vyapaar-market-indicators`
remains the single indicator crate in the ecosystem.
