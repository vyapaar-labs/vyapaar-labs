# 0005 — `vyapaar-runtime-market` and `vyapaar-runtime-test-utils` are empty stubs

**Status**: open

**Provider repo**: `vyapaar-runtime`

## What's stubbed or hardcoded

- `vyapaar-runtime/crates/vyapaar-runtime-market/src/lib.rs` — one comment line:
  `// Stub crate: vyapaar-me-market`. Nothing imports `vyapaar_runtime_market` in code.
- `vyapaar-runtime/crates/vyapaar-runtime-test-utils/src/lib.rs` — one comment line:
  `// Stub crate: vyapaar-testing`. Nothing imports `vyapaar_runtime_test_utils` in code.

Both are registered in `vyapaar-runtime/Cargo.toml` `members` and `workspace.dependencies`.
`vyapaar-runtime-api-rest` lists `vyapaar-runtime-market` in its own `[dependencies]` via
`vyapaar-runtime-market.workspace = true`, but never uses it.

## Why

Legacy `honba-me-market` and `honba-testing` scaffold leftovers. The actual runtime
market-repository functionality lives in `vyapaar-runtime-persistence` and
`vyapaar-runtime-strategy`; the actual test helpers live in `vyapaar-runtime-testing`.

## How to close it

1. Remove both crates' directories and their `members` + `workspace.dependencies` entries in
   `vyapaar-runtime/Cargo.toml`.
2. Remove the now-dangling `vyapaar-runtime-market.workspace = true` line from
   `vyapaar-runtime-api-rest/Cargo.toml`.
3. Keep `vyapaar-runtime-testing` as the single test-helper crate.
4. Verify: `cd vyapaar-runtime && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes without the stubs; grep confirms no
`vyapaar_runtime_market` / `vyapaar_runtime_test_utils` imports remain anywhere.
