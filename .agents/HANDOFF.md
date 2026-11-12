# HANDOFF — vyapaar-labs

**Status**: Bottoms-up Fincept/Quantcept gap-closing build order
(`docs/future-work-bottoms-up-build-order.md`) — Layers 0, 1, 2, 2b, 3, 4, 5, 6 GREEN;
Level 7 (`vyapaar-data/0002`, filings breadth) partially superseded: filings ingestion itself
landed (closed gap `vyapaar-data/docs/gaps/0003`). Agent-side **plan 0006 (MCP/chat tool
catalog expansion) is complete**; follow-on breadth tracked under agent plan 0007. Two
upstream bridges remain open on the provider side:
`vyapaar-data/docs/gaps/0007-filings-rust-bridge.md` (filings) and
`vyapaar-market/docs/gaps/0001-options-chain-reader.md` +
`vyapaar-data/docs/gaps/0008`/`0009` (options chain, corporate actions).
Date: 2026-11-12 · Workspace: `vyapaar-labs`
Playbook: `docs/future-work-bottoms-up-build-order.md` (execution order, by crate dependency
depth). The repo-migration (`honba-*` → `vyapaar-*`, Tier 0–6) that used to be this file's whole
subject is complete and long superseded — see "Prior work" below.

## Latest Batch — resolve rebase conflicts (vyapaar-agent, vyapaar-data, vyapaar-adapters, vyapaar-market)

Date: 2026-11-12. Resolved merge conflicts arising during interactive rebase onto `origin/main`:
- `vyapaar-agent`: Resolved plan numbering collision between upstream roadmap dismantling
  (renumbered active plans to 0008/0009) and the institutional/smart-money flow detection suite.
  Renumbered smart-money plan to `0010`, updated upstream gap dependencies to data `0013`/`0014`,
  and updated `docs/plans/README.md` and `.agents/HANDOFF.md`. Rebased to `32b37c7`.
- `vyapaar-data`: Resolved gap numbering collision between upstream roadmap dismantling
  (which claimed 0010–0012) and the new FII/DII flow and delivery percentage gaps.
  Renumbered them to gaps `0013` and `0014`, linked to agent plan `0010`, and updated
  `docs/gaps/README.md`. Rebased to `a370be5`.
- `vyapaar-adapters`: Resolved rebase conflicts against dismantled roadmap (confirmed removal
  of `docs/roadmap/`), merged competing `code-config.md` additions, folded Phase D (Improvements)
  into active plan `0002`, preserved plans `0003` & `0004`, integrated section 5 per-module doc
  map in `architecture.md`, and updated gaps `0001`–`0007`. Rebased to `8d7c440`.
- `vyapaar-market`: Updated plan reference in gap `0002-open-interest-history-and-buildup-tracking.md`
  from agent plan 0008 to 0010. Committed as `87ed5aa`.
- All submodule working trees clean, `pytest` passes in `vyapaar-adapters` (44 passed) and
  `vyapaar-data` (86 passed).

## Prior batches (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Adapters documentation sync (vyapaar-adapters + vyapaar-docs, 2026-11-12)**:
  `vyapaar-adapters` per-module design docs (`code-parse.md`, `code-config.md`,
  `code-codec.md`, `code-public-api.md`), gaps 0001–0007 refreshed; `vyapaar-docs` updated
  with `docs/api/adapters-package.md`, `india/adapter_configuration.md`, etc.

- **Plan 0006 Phase 4 (2026-11-12)** — `options_chain`/`corporate_actions` chat
  tools; research re-verified upstream first (`vyapaar-market` had no chain
  reader; `vyapaar-data` corporate-actions reader exists Python-side). Gaps
  filed before tool code: `vyapaar-market/docs/gaps/0001-options-chain-reader.md`,
  `vyapaar-data/docs/gaps/0008-corporate-actions-rust-bridge.md` + `0009`.
  Landed: `OptionContract`/`OptionsChain`/`CorporateAction` DTOs,
  `MarketReader::options_chain`/`corporate_actions`, 2 ReadOnly tools
  (catalogue **17 → 19**), honest `FeedMarketReader` stubs + seedable
  `RuntimeMarketReader` stores. **Plan 0006 complete (Phases 1–4)**, doc
  retired to agent `docs/plans/README.md` Implemented table; follow-on breadth
  under agent plan 0007. Commits: agent `127597d`+`a0817a6`, runtime `bcd1c76`,
  market `d4e3c76`, data `0bc5edd`. All gates re-verified 2026-11-12 (fmt /
  clippy `-D warnings` / `cargo test --workspace --profile prod` 0 failed /
  fresh `make prod` each).
- **Plan 0006 Phase 3 (2026-11-12)** — `news_search`/`filings_search` via new
  `ContentReader` port (catalogue 15 → 17); gaps `vyapaar-data/docs/gaps/0006`+`0007`
  filed. Commits: agent `98c66c2`, runtime `96e878f`, data `3ee4005`.
- **Plan 0006 Phases 1–2 (2026-11-11)** — `BlockDealsTool` (`MarketReader::block_deals`,
  honest runtime stub citing `vyapaar-data` gap 0005, runtime plan 0004 Phases 1–3)
  and `PriceAlertTool` CRUD (`AlertReader`/`AlertWriter`, `price_alert_list`/`price_alert`,
  `Profile.alerts` storage). Catalogue 14 → 15 read-only + 2 alert tools
  (agent `a72689c`, runtime `d54f140`).
- **Fincept/Quantcept gap-closure batch (2026-11-06)** — Layers 0–6 GREEN
  (per-layer table with commits in this file's git history; `vyapaar-core` 9ce4880,
  `vyapaar-ledger` b35a314, `vyapaar-risk` 5b00cda, `vyapaar-market` ddb5c3f+1983512,
  `vyapaar-exec` 2675c07+ed3a6b3, `vyapaar-strategies` 207a70c, `vyapaar-agent` 36b0d53/1f9fb13/
  51b024d/236f8eb/5470e7b, `vyapaar-ui` 2cda245+acdc137, `vyapaar-examples` 552c873,
  `vyapaar-docs` 1267490). Key decisions preserved: core enables rust_decimal `maths`;
  `BrokerEnumMap<T>` table-driven wire mapping (Layer 2); **crypto execution NO-GO** (fresh
  scope review required to revisit); Python adapters dev/research-only; forecast/panel compute
  f64-internal with exact-Decimal boundaries; duplicate `LlmProvider` in agent-core deleted in
  favor of `vyapaar-agent-llm`; 0004 Phase 4 local SLM deferred by design. Session also landed
  `vyapaar-ledger` plan 0002 (`vyapaar-ledger-performance`, 2a3a04e), `vyapaar-data` gaps
  0001+0002 (261d646), `vyapaar-runtime` plan 0003 (trade-journal + market-reference endpoints;
  sample stores pending the `vyapaar-data` → Rust FFI bridge).

## Prior work (collapsed per `.agents/rules/handoff-hygiene.md`)

- **Tier 0–6 repo migration** (`honba-*` → `vyapaar-*` submodules, incl. Tier 4 `vyapaar-ffi`'s
  codegen/PyO3/Arrow bridge/Python SDK): complete. Full per-tier detail (gate reports, slice
  tables, Tier-0-specific design notes) lived here until 2026-11-06; trimmed now that it's long
  superseded by Tiers 5–6 and this file's current "Latest Batch" above. See commits
  `feat(tier-0)` through `feat(tier-6)` in this repo's git log for the full record; the migration
  guide that used to be this file's "Playbook" pointer was retired in `4b5d9f9`.
- **Submodule updates (2026-11-09)**:
  - `vyapaar-examples`: All 9 stages (0–8) of `honba-examples` staged port landed (`docs/plans/0002` Implemented); full test suite (922 passed, 70 skipped), master index `examples/README.md`, and docs completed.
  - `vyapaar-runtime`: **PLAN-0001 complete (Stages 1–4)** — RunId/`FileJournalWriter`/recovery (`60a5bd9`), bounded worker pool with 429 backpressure + `FileJobRegistry` (approvals queue, fencing leases, budgets) + Vixie cron scheduler + broker dispatch behind the SEBI risk gate (`46817a0`); plan/gap docs retired (`4bd4ef5`). Remaining open: GAP-0003 (broker wire transports), PLAN-0002 (statistical gates).
  - `vyapaar-ui`: **PLAN-0001 Stage 4 CLI half landed** — `vyapaar jobs run/tick/logs` on the runtime pool + per-run journals (`vyapaar jobs add ... -> tick -> journal verified` acceptance suite, 11 e2e tests) + agent tool-call journals + approvals gating (`0b9241d`); clippy-driven fixups (breach-first refusal for PendingApproval jobs) follow-up. Open: ui-core trade rows (`vyapaar-ui/docs/gaps/0002`).

## Immediate Next Step
1. Plan 0006 is complete (Phases 1–4); agent plan 0007 is the active follow-on master guide for
   future chat-tool/MCP-gateway breadth. Closing `vyapaar-data/docs/gaps/0007-filings-rust-bridge.md`
   (the standing `vyapaar-data` → Rust FFI bridge) unblocks both the chat `filings_search` tool
   and the runtime market-reference sample stores; `vyapaar-market/docs/gaps/0001` +
   `vyapaar-data/docs/gaps/0008`/`0009` similarly block the options-chain/corporate-actions tools
   from returning real data (both currently answer with honest `PortError::unavailable`).
2. Remaining per-repo follow-ups (non-blocking, tracked in each repo's HANDOFF / `docs/gaps/`):
   - **4B Phase 4 (local SLM)** — deferred by design; prerequisite is the Phase-3 golden fixture set accumulating via live OmniRoute runs (`VYAPAAR_WRITE_FIXTURES=1`), then model licensing/fine-tuning/quantization per `0005`.
   - **0001 Phase 1** (`vyapaar_search_tools`/`vyapaar_describe_tool` two-tier gateway) — the forecast engine is currently discoverable via `tools/list` only; once the gateway lands, add the `forecast` category to its category enum.
   - **`vyapaar-ui`** — Leptos view layer for `vyapaar-ui-app`, wire CLI `ask`/`scan` (gap `vyapaar-ui/docs/gaps/0001`), TUI `run()` event loop.
3. Layer 3's `BasketManifest` consumption lands in `vyapaar-runtime-backtest` (catalog.rs/engine.rs) as a separate future slice, per the plan's scope note.

## Operating Invariants
- Toolchain: `cargo 1.97.1` / `rustc 1.97.1`; edition 2024, `rust-version = "1.85"`.
- Zero inline `#[test]` / `#[cfg(test)]` in `src/**/*.rs` (Parallel Test Directory Rule, AGENTS.md §3.2).
- Wire compatibility: `Price`/`Quantity` remain string-encoded decimals (`serde-with-str`); `-0.00` parses to `Decimal::ZERO` semantics (not negative-strict), matching upstream rust_decimal behavior.
- `.agents/rules/subagent-discipline.md`, `.agents/rules/no-recon.md`, `.agents/rules/gap-tracking.md`, `.agents/rules/handoff-hygiene.md` are binding workspace-wide — see `AGENTS.md` §8–§10.
- Plan & Gap discipline: when implementing a plan or gap, any hardcoded/stubbed/sample data used requires filing a `docs/{plans,gaps}/XXXX-*.md` in the respective provider repo (gaps = individual features, plans = collections of gaps). When implemented, the document is cleaned up from active `docs/{plans,gaps}/` and recorded in the repo's index.
