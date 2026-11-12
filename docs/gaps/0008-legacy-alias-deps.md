# 0008 — `vyapaar-runtime` `workspace.dependencies` carries unused legacy honba aliases

**Status**: open

**Provider repo**: `vyapaar-runtime`

## What's stubbed or hardcoded

`vyapaar-runtime/Cargo.toml` `[workspace.dependencies]` still declares four legacy alias entries
that exist only to preserve old `honba` names:

```toml
vyapaar-api-rest = { path = "crates/vyapaar-runtime-api-rest" }
vyapaar-api = { path = "crates/vyapaar-runtime-api" }
vyapaar-backtest = { path = "crates/vyapaar-runtime-backtest" }
vyapaar-actors = { path = "crates/vyapaar-runtime-actors" }
```

No crate in any workspace depends on `vyapaar-api-rest`, `vyapaar-api`, `vyapaar-backtest`, or
`vyapaar-actors` as a dependency name (verified by grepping all `Cargo.toml` files). The real
canonical names (`vyapaar-runtime-api-rest`, `vyapaar-runtime-api`, `vyapaar-runtime-backtest`,
`vyapaar-runtime-actors`) are used everywhere instead.

## Why

Migration-era compatibility aliases from the `honba-*` → `vyapaar-*` rename. The consumers that
used the old names have long since been ported to the canonical names.

## How to close it

1. Delete the four legacy alias entries from `vyapaar-runtime/Cargo.toml` `[workspace.dependencies]`.
2. Confirm no `Cargo.toml` in any workspace references the aliases (`grep -rn "vyapaar-api\b\|vyapaar-api-rest\|vyapaar-backtest\|vyapaar-actors"` across `--include=Cargo.toml`).
3. Verify: `cd vyapaar-runtime && cargo check --workspace --profile prod && make test`.

## Verification

`cargo check --workspace --profile prod` passes with the aliases removed; grep shows no remaining
references to the legacy names.
