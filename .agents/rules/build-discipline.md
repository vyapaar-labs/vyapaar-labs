# Rule: Build & Profile Discipline (prod Invariant)

**Status: binding for every orchestrator/parent session and every spawned subagent in this workspace.**

## 1. Default Profile is ALWAYS `prod`
- In this ecosystem, the canonical build and execution target is **`prod`** (`target/prod`).
- Subsystems (Candle GGUF local inference, zero-copy Arrow memory bridge, SEBI pre-trade risk engine) rely on `opt-level = 3` and LTO. Unoptimized `dev` debug builds are order-of-magnitude slower and are never what the user tests.

## 2. Strictly Forbidden Commands
- **DO NOT** run bare `cargo build` (it compiles to `target/debug` and leaves `target/prod` stale).
- **DO NOT** run `cargo build --release` (it compiles to `target/release`, which is not the workspace target).
- **DO NOT** run `cargo test --release` or `cargo test --all` without `--profile prod`.

## 3. Mandatory Commands
- **To build**:
  - Across whole workspace: `make prod` (from workspace root)
  - Single repository: `make prod` or `cargo build --workspace --profile prod`
- **To test**:
  - Across whole workspace: `make test`
  - Single repository: `make test` or `cargo test --workspace --profile prod`
- **To check**:
  - Across whole workspace: `make check`
  - Single repository: `make check` or `cargo check --workspace --profile prod`

## 4. End-of-Turn Invariant
- Before completing any turn, declaring a task done, or updating `HANDOFF.md` for a task that modified Rust code, the agent **MUST** run `make prod` (or `make -C <subrepo> prod`).
- Leaving `target/prod/` stale when claiming a code change is finished is a violation of reporting integrity.
