# Plans Index — `vyapaar-labs`

Master architecture and cross-subsystem plans for the Vyapaar platform.
Per workspace rule `.agents/rules/gap-tracking.md`:
- Gaps are individual features (`docs/gaps/XXXX-*.md`).
- Plans are collections of gaps (`docs/plans/XXXX-*.md`).
- When implemented, plan documents are cleaned up from `docs/plans/` and recorded in this index.

## Active Plans

| # | Title | Target Scope | Status |
|---|-------|--------------|--------|
| [0001](0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md) | Fincept & Quantcepts Feature Parity, Gap Closure, and Platform Expansion Master Plan | Platform-wide | Approved Architecture & Implementation Roadmap |

## Implemented Plans

| # | Title | Target Scope | Implemented In |
|---|-------|--------------|----------------|
| 0002 | Strategy Execution, Hyperparameter Tuning, and Optimal Trade Suggestion Engine for CLI & TUI | `vyapaar-agent`, `vyapaar-ui`, `vyapaar-runtime` | Phases 1–5 Complete (`vyapaar-agent` 85d3c07, `vyapaar-ui` 1beb69f + 06940c5, `vyapaar-runtime` 60a5bd9) |


I have launched task-112 to search for references to root plan 0002. I will wait for it to complete before proceeding.

I have added the rule to `.agents` and cleaned up the implemented plans and gaps across all repositories in the workspace.

### 1. Updated `.agents` Rules
Updated [`.agents/rules/gap-tracking.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/.agents/rules/gap-tracking.md) and [`.agents/AGENTS.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/.agents/AGENTS.md) (§9) with the binding **Plan & Gap Tracking Rule**:
- **Definitions**:
  - **Gaps** (`docs/gaps/XXXX-*.md`): Individual features, endpoints, or stubs.
  - **Plans** (`docs/plans/XXXX-*.md`): Collections of gaps or multi-phase architectural features.
- **Upstream Provider Filing**:
  - When implementing a plan/gap, if any hardcoded, stubbed, mock, or sample data is used, a `docs/{plans,gaps}/XXXX-*.md` document must be added to the **respective repository that is supposed to provide the functionality** (the upstream owning repo).
  - In the consuming repo, the stub/workaround must cite the dependency with a code comment (e.g., `// stand-in for vyapaar-core/docs/gaps/0001-*.md`) and in the commit message.
- **Cleanup of Implemented Items**:
  - Once a plan or gap is implemented and verified, the document is cleaned up (removed from active `docs/{plans,gaps}/`).
  - The repository's index table (`docs/plans/README.md` or `docs/gaps/README.md`) and any referencing indices (such as [`docs/future-work-bottoms-up-build-order.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/docs/future-work-bottoms-up-build-order.md)) are updated to record completion details and closing commits without broken file links.
- Synced the rule across submodules (symlinked `.agents/rules` in `vyapaar-examples` and updated `vyapaar-ui-web/.agents`).

---

### 2. Workspace-Wide Repository Cleanup and Index Updates

Across all repositories, cleaned up completed plan/gap markdown documents from `docs/{plans,gaps}/` and established or updated the respective `README.md` index files:

| Repository | Active / Open | Implemented / Closed Cleaned Up | Index File |
| :--- | :--- | :--- | :--- |
| **`vyapaar-labs` (root)** | Plan `0001` (Master Roadmap) | Plan `0002` (Strategy Execution, Tuning & Suggestions) | [`docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/docs/plans/README.md) |
| **`vyapaar-core`** | Plan `0001` (Phase 2 call-site consolidation open) | Plan `0001` Phase 1 landed in `9ce4880` + `43a11f0` | [`vyapaar-core/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-core/docs/plans/README.md) |
| **`vyapaar-ledger`** | Plan `0001` (Phases 2–4 open) | Plan `0001` Phase 1 landed in `b35a314` | [`vyapaar-ledger/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-ledger/docs/plans/README.md) |
| **`vyapaar-market`** | Plan `0001` (Phase 4 open) | Plan `0001` Phases 1–3 landed in `ddb5c3f` + `602a710` | [`vyapaar-market/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-market/docs/plans/README.md) |
| **`vyapaar-exec`** | *(None)* | Plan `0001` (Wire-mapping in `2675c07`, crypto resolved NO-GO in `d529bc9`) | [`vyapaar-exec/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-exec/docs/plans/README.md) |
| **`vyapaar-adapters`** | *(None)* | Plan `0001` (Python/Rust adapter boundary resolved in `4f497aa`) | [`vyapaar-adapters/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-adapters/docs/plans/README.md) |
| **`vyapaar-ffi`** | *(None)* | Plan `0001` (Python bridge policy adopted in `c7bc420`) | [`vyapaar-ffi/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-ffi/docs/plans/README.md) |
| **`vyapaar-strategies`**| *(None)* | Plan `0001` (Versioned manifests & baskets landed in `207a70c`) | [`vyapaar-strategies/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-strategies/docs/plans/README.md) |
| **`vyapaar-risk`** | *(None)* | Plan `0001` (Tool annotation hooks landed in `5b00cda`) | [`vyapaar-risk/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-risk/docs/plans/README.md) |
| **`vyapaar-examples`** | Gaps `0001`–`0008` (wheel mirrors) | Plans `0001` (in `552c873`) and `0002` (in `bbfa692`) | [`vyapaar-examples/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-examples/docs/plans/README.md) |
| **`vyapaar-agent`** | Plans `0001`, `0002`, `0004` (P4 deferred), `0005` | Plan `0003` (Forecast, panel, report engines in `51b024d` + `236f8eb`) | [`vyapaar-agent/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-agent/docs/plans/README.md) |
| **`vyapaar-ui`** | Plans `0001`–`0003`, Gap `0001` (scan open) | Plans `0004` (CLI/TUI ref) and `0005` (Screen inventory in `2cda245` + `acdc137`) | [`vyapaar-ui/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-ui/docs/plans/README.md) |
| **`vyapaar-docs`** | Plan `0001` | Plan `0002` (Fincept/Quantcept mapping & OmniRoute setup in `1267490`) | [`vyapaar-docs/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-docs/docs/plans/README.md) |
| **`vyapaar-data`** | Plans `0001`, `0002` | Gap `0001` (Catalog coverage verified in `56d8ba1`) | [`vyapaar-data/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-data/docs/plans/README.md) |
| **`vyapaar-runtime`** | Plans `0001`–`0002`, Gaps `0001`–`0002` | *(Active development in progress)* | [`vyapaar-runtime/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-runtime/docs/plans/README.md), [`vyapaar-runtime/docs/gaps/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-runtime/docs/gaps/README.md) |
| **`vyapaar-ui-web`** | Plans `0001`–`0008`, 41 Open Gaps | Plans `0009` (Chart library choice) and `0010` (Unified workspace shell); recorded 17 closed gaps (`0003`, `0008`, `0011`, `0019`, `0025`, `0026`, `0031`, `0032`, `0034`, `0035`, `0036`, `0037`, `0041`, `0050`, `0052`, `0056`, `0058`) in Closed Gaps index | [`vyapaar-ui-web/docs/plans/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-ui-web/docs/plans/README.md), [`vyapaar-ui-web/docs/gaps/README.md`](file:///home/pmallapp/Devel/Finance/vyapaar-labs/vyapaar-ui-web/docs/gaps/README.md) |
