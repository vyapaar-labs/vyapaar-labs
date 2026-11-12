# 0001 — `vyapaar-market` broker WS feed crates are empty stubs

**Status**: open

**Provider repo**: `vyapaar-market`

## What's stubbed or hardcoded

The following crates are registered in `vyapaar-market/Cargo.toml` `[workspace] members` and
`[workspace.dependencies]`, but their `src/lib.rs` is a single doc-comment line with no
implementation:

- `vyapaar-market-zerodha`
- `vyapaar-market-upstox`
- `vyapaar-market-fyers`
- `vyapaar-market-angelone`
- `vyapaar-market-dhan` (70 lines: defines a `DhanFeed` struct implementing `MarketDataFeed` but
  returns an empty stream; no Dhan WebSocket wire protocol)

## Why

The workspace was scaffolded with all planned broker adapters up front so the crate list would
match the architecture doc. The real brokers (Zerodha Kite, Upstox, Fyers, Angel One, Dhan) have
binary WebSocket wire formats that are non-trivial; the crates were never populated. Nothing in any
workspace imports these crates (`grep -rl "vyapaar_market_zerodha\|..._upstox\|..._fyers\|..._angelone\|..._dhan"` across all repos returns only their own `Cargo.toml`).

## How to close it

1. Remove `vyapaar-market-zerodha`, `-upstox`, `-fyers`, `-angelone`, `-dhan` from
   `vyapaar-market/Cargo.toml` `members` and `workspace.dependencies` (one commit, atomic).
2. Do **not** delete the plan to add real broker feeds — re-add each crate only when its WS
   wire protocol is actually implemented (per gap-tracking §4, deleting a stub is not closing the
   feature, but re-adding an empty stub is forbidden).
3. Update `vyapaar-market/docs/gaps/README.md` index if a per-repo gap was filed there.
4. Verify: `cd vyapaar-market && cargo check --workspace --profile prod` and `make test`.

## Verification

`cargo check --workspace --profile prod` passes without the crates present; no other workspace
declares a path dependency on the removed crates.
