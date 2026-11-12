# 0006 — `vyapaar-exec-angelone` is a near-empty stub

**Status**: open

**Provider repo**: `vyapaar-exec`

## What's stubbed or hardcoded

`vyapaar-exec/crates/vyapaar-exec-angelone/src/lib.rs` is 9 lines — essentially empty, with only
`vyapaar-core`, `serde`, `thiserror` in `[dependencies]` and no broker/order logic. Compare the
real siblings `vyapaar-exec-zerodha` (1,549 lines) and `vyapaar-exec-upstox` (1,333 lines).

## Why

The Angel One SmartAPI execution adapter was scaffolded during migration but never implemented
(the architecture requires ACL translation between Angel One's JSON SmartAPI wire format and
`vyapaar-core` canonical order types). Nothing imports `vyapaar_exec_angelone` in code.

## How to close it

1. Either **implement** the Angel One execution adapter (ACL: `angelone_json` ↔ `vyapaar_core`,
   per `docs/ddd-conflict.md` Conflict #6), or
2. **Remove** `vyapaar-exec-angelone` from `vyapaar-exec/Cargo.toml` `members` and
   `workspace.dependencies` until it is actually implemented (re-adding an empty stub is
   forbidden).
3. Update `vyapaar-exec/docs/plans/README.md` or `docs/gaps/README.md` index as appropriate.
4. Verify: `cd vyapaar-exec && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes; the crate is either real (clippy-clean, has
`tests/`) or absent.
