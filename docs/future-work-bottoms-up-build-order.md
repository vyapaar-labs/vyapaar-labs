# Bottoms-up build order for the Fincept/Quantcept gap-closing plans

This is a build-sequencing companion to the 14 `docs/plans/*.md` files written in this round of
planning, listed below by exact path. Those docs were organized **top-down** — one per repo,
grouped by which Fincept/Quantcept feature maps to which bounded context. This document re-sorts
the same work **bottoms-up**: by actual crate dependency depth, so a reader (or an implementing
agent) knows what to build first without re-deriving the dependency graph from 14 separate files.

Scope note: this document covers only the 14 docs listed below. It does not reference or attempt
to reconcile the separate, pre-existing `docs/plans/0001-fincept-quantcepts-gap-closure-and-feature-roadmap.md`
at this same path depth — that is a different initiative and is left untouched here.

The 14 docs, for reference:

1. `vyapaar-core/docs/plans/0001-canonical-quant-transform-primitives.md`
2. `vyapaar-ledger/docs/plans/0001-portfolio-allocation-and-optimization.md`
3. `vyapaar-risk/docs/plans/0001-mcp-tool-annotation-hooks.md`
4. `vyapaar-market/docs/plans/0001-technicals-breadth-and-derivatives-pricing.md`
5. `vyapaar-exec/docs/plans/0001-crypto-execution-and-broker-wire-mapping.md`
6. `vyapaar-ffi/docs/plans/0001-python-bridge-policy-for-quant-engines.md`
7. `vyapaar-strategies/docs/plans/0001-versioned-strategy-manifests-and-baskets.md`
8. `vyapaar-adapters/docs/plans/0001-python-rust-broker-adapter-boundary.md`
9. `vyapaar-examples/docs/plans/0001-fincept-gap-closing-examples.md`
10. `vyapaar-agent/docs/plans/0003-remaining-fincept-analytics-engines.md`
11. `vyapaar-agent/docs/plans/0004-free-tier-llm-backend-and-deferred-local-slm.md`
12. `vyapaar-ui/docs/plans/0005-fincept-terminal-screen-inventory.md`
13. `vyapaar-data/docs/plans/0002-filings-and-econ-series-breadth.md`
14. `vyapaar-docs/docs/plans/0002-fincept-quantcept-mapping-and-local-llm-docs.md`

---

## Why bottoms-up, and what "layer" means here

Vyapaar's own `AGENTS.md` already enforces a dependency direction (`vyapaar-core` is the shared
kernel; `vyapaar-ledger`/`vyapaar-risk`/`vyapaar-market` depend only on it; `vyapaar-exec` sits
above market data; `vyapaar-runtime` orchestrates; `vyapaar-agent` depends on core/risk and reads
the others through inverted ports (R1–R5); `vyapaar-ui` depends on everything through read ports).
Building in dependency order, lowest layer first, means every later layer can actually use the
thing below it instead of mocking it and reworking later. Building top-down by feature (as the
per-repo docs are organized) is the right way to *scope* the work; it is the wrong order to
*execute* it in.

A "layer" below is a set of docs whose crates don't depend on each other, so they can be built in
any order, or in parallel, once the layer below them is in place.

---

## Layer 0 — Kernel (zero dependencies)

**`vyapaar-core/docs/plans/0001-canonical-quant-transform-primitives.md`**

Build this first. Returns, realized/EWMA volatility, and rolling-stat primitives are needed by at
least three other docs in this list (`vyapaar-ledger`'s allocation objectives need covariance/
returns; `vyapaar-market`'s pricing crate needs volatility for Black-Scholes; `vyapaar-agent`'s new
forecast engine needs return/feature series). None of those crates have a *hard* compile-time
dependency on this landing first — they could each re-derive the same math — but doing so means
three separate, slightly-different implementations of "what is a return" to maintain. Land this
once, here, before starting any of Layer 1.

---

## Layer 1 — Domain crates depending only on `vyapaar-core`

These three are mutually independent. Any order, or parallel, once Layer 0 is in place.

- **`vyapaar-ledger/docs/plans/0001-portfolio-allocation-and-optimization.md`** — new
  `vyapaar-ledger-allocation` crate. Its own Phase 1 (mean-variance + risk parity) is the smallest
  useful slice and the right place to start within this doc.
- **`vyapaar-risk/docs/plans/0001-mcp-tool-annotation-hooks.md`** — smallest doc in the whole set
  (one enum, one pure function). No reason to delay it; it has no dependents waiting on it either,
  so its position in the sequence is flexible, but doing it early is nearly free.
- **`vyapaar-market/docs/plans/0001-technicals-breadth-and-derivatives-pricing.md`** — three
  sub-tracks inside this one doc that are themselves independent of each other: indicator breadth
  (Phase 1), the new `vyapaar-market-pricing` crate (Phase 2), and the broker wire-mapping
  verification (Phase 3). The wire-mapping verification (Phase 3) should actually happen **early**,
  in lockstep with the next layer — see below.

---

## Layer 2 — Verification gate shared with execution

**`vyapaar-exec/docs/plans/0001-crypto-execution-and-broker-wire-mapping.md`**, Phase 1, run
together with `vyapaar-market/docs/plans/0001`'s Phase 3 (both docs say so explicitly — they're
the same underlying question, data-side and execution-side). Do this pairing early rather than
late: if the broker crates already have ad-hoc if-chains, finding that out before anything else in
this list touches those crates means a refactor doesn't have to be threaded through new work later.
The crypto-execution scope decision in the same doc (its Phase 2, a go/no-go checkpoint) can happen
any time after — it has no dependents in this list regardless of its answer.

---

## Layer 2b — Decision/policy gates (cheap, no code, but should be settled before the layers that follow)

These two docs produce no new engine code themselves — they produce a decision or a standing rule
that later layers should already know the answer to, so settle them early and cheaply rather than
discovering mid-implementation that a question was never actually answered.

- **`vyapaar-adapters/docs/plans/0001-python-rust-broker-adapter-boundary.md`** — resolve which of
  the three stated resolutions is true *before* any later doc in this list (or outside it) adds new
  broker/venue scope to either the Python adapters or the Rust broker crates.
- **`vyapaar-ffi/docs/plans/0001-python-bridge-policy-for-quant-engines.md`** — a standing policy,
  not a crate. Relevant the moment anyone starts implementing a Python-first version of any engine
  this round of planning named (Panel, Forecast, anything GARCH/HMM/copula-shaped if those ever get
  picked up) — settle it before that happens, which in this list is Layer 4 (`vyapaar-agent/0003`).

---

## Layer 3 — Strategy layer (parallel, low-coupling with everything above)

**`vyapaar-strategies/docs/plans/0001-versioned-strategy-manifests-and-baskets.md`** — depends
conceptually on `vyapaar-runtime-backtest`/`vyapaar-runtime-strategy` (cited, not modified, by that
doc) but not on anything in Layers 0–2 above. Can start as soon as convenient; has no hard ordering
constraint with the rest of this list.

---

## Layer 4 — Agent (AI reasoning layer; two independent tracks)

These two docs are **two separate tracks** that don't block each other — they touch almost
entirely different crates inside `vyapaar-agent`. Worth stating explicitly so neither is mistaken
for a prerequisite of the other. **Both tracks are implemented** (see
`vyapaar-agent/docs/plans/0003` and `0004`, both marked implemented):

- **Track A — quant-engine expansion**: `vyapaar-agent/docs/plans/0003-remaining-fincept-analytics-engines.md`.
  Benefits from Layer 0 landing first (its `vyapaar-agent-forecast` crate wants the return/series
  primitives) and from the Layer 2b `vyapaar-ffi` policy being settled (in case `vyapaar-agent-panel`
  ends up prototyped in Python first). Internally, its own Phase 1 (`vyapaar-agent-forecast`) is
  the highest-value piece; Phase 3 (`vyapaar-agent-panel`) is explicitly the one that can slip.
- **Track B — LLM serving infrastructure**: `vyapaar-agent/docs/plans/0004-free-tier-llm-backend-and-deferred-local-slm.md`.
  This track is independent of every other doc in this list — it touches `vyapaar-agent-llm`,
  `vyapaar-agent-trader-loop`, `vyapaar-agent-chat`, `vyapaar-agent-research`, `vyapaar-agent-report`'s
  LLM-calling plumbing, not any of the quant-math crates above. It can start as soon as its own
  Phase 1 is approved for implementation, in parallel with Layers 0–3, rather than waiting for them.
  Its own internal order is strict (Phase 1 → 2 → 3 → 4, local SLM explicitly last) and is already
  fully specified inside that doc. Phase 4's model licensing, fine-tuning, quantization, and
  determinism detail lives in a companion reference doc,
  `vyapaar-agent/docs/plans/0005-local-slm-model-selection-and-reliability-reference.md` — it is
  supporting material for this step, not a separate item in the build order.

---

## Layer 5 — UI (presentation; depends on everything above through read ports)

**`vyapaar-ui/docs/plans/0005-fincept-terminal-screen-inventory.md`** — deliberately last. Every
screen this doc proposes is a thin view over a domain crate from a lower layer (watchlist over
`vyapaar-market`, screener over the existing — currently dual — screener backends, portfolio view
over `vyapaar-ledger-portfolio` and, once it exists, `vyapaar-ledger-allocation`'s target weights,
algo management over `vyapaar-strategies`' new manifests). Building any of these screens before the
crate underneath it exists means building against a mock that gets reworked the moment the real
crate lands — there is no benefit to starting this layer early. **Implemented** — all three phases
landed in `vyapaar-ui` (Watchlist/Dashboard + Screener + Backtest results viewer + Portfolio view +
Algo management; the two-screener question was resolved to the canonical `vyapaar_core::screener`
wire contract; see the plan doc's status header).

---

## Layer 6 — Triggered deferred items (implemented)

Two of the three docs flagged below as "deferred / triggered-by-completion" had their triggers fire
once Layers 1–5 shipped. **Both are implemented**:

- **`vyapaar-examples/docs/plans/0001-fincept-gap-closing-examples.md`** — **implemented**. One
  runnable example per shipped engine: `examples/12_portfolio_allocation`
  (`vyapaar-ledger-allocation` mirror: mean-variance tangency, damped risk parity, bounds),
  `examples/13_black_scholes_greeks` (`vyapaar-market-pricing` mirror: Black-Scholes price, five
  Greeks, IV bisection), `examples/14_timeseries_forecast` (`vyapaar-agent-forecast` Theta mirror),
  `examples/15_fama_macbeth_factor_regression` (`vyapaar-agent-panel` two-pass mirror), plus shared
  exact-Decimal stats/linear-algebra helpers in `vyapaar_examples/quant.py` and per-example
  regression tests in `tests/unit/`. Commit `vyapaar-examples` 552c873.
- **`vyapaar-docs/docs/plans/0002-fincept-quantcept-mapping-and-local-llm-docs.md`** —
  **implemented**. Terminology disambiguation (`docs/ai/fincept-vs-quantcept.md` — no gate) and the
  OmniRoute setup guide (`docs/ai/omniroute_setup.md` — gated on Track B, Layer 4, reaching Phase 2,
  which shipped), linked from `docs/ai/index.md` and the MkDocs nav. Commit `vyapaar-docs` 1267490.

---

## Level 7 — Remaining deferred (still gated)

These docs remain "wait for a trigger," not "build now." They don't occupy a position in the
sequence above because they're gated on a trigger firing, not on a dependency being ready:

- **`vyapaar-data/docs/plans/0002-filings-and-econ-series-breadth.md`** — still deferred, by its own
  gate: revisit filings ingestion once a concrete consumer (a screener field, a research hypothesis)
  actually needs filings data — do not build a generic filings pipeline speculatively.

---

## Summary table

| Step | Doc | Crates touched | Depends on |
|---|---|---|---|
| 0 | `vyapaar-core/0001` | `vyapaar-core` | nothing |
| 1a | `vyapaar-ledger/0001` | new `vyapaar-ledger-allocation` | Layer 0 (soft) |
| 1b | `vyapaar-risk/0001` | `vyapaar-risk` | nothing |
| 1c | `vyapaar-market/0001` (Phases 1–2) | `vyapaar-market-indicators`, new `vyapaar-market-pricing` | Layer 0 (soft, for pricing) |
| 2 | `vyapaar-market/0001` Phase 3 + `vyapaar-exec/0001` Phase 1 | `vyapaar-market-*`, `vyapaar-exec-*` broker crates | nothing, but should happen jointly |
| 2b | `vyapaar-adapters/0001`, `vyapaar-ffi/0001` | decisions/policy only | nothing |
| 3 | `vyapaar-strategies/0001` | `vyapaar-strategies`, cross-refs `vyapaar-runtime-*` | nothing |
| 4A | `vyapaar-agent/0003` | new `vyapaar-agent-forecast`/`vyapaar-agent-panel`, extend `vyapaar-agent-analytics` | Layer 0, Layer 2b (`vyapaar-ffi`) |
| 4B | `vyapaar-agent/0004` | `vyapaar-agent-llm` and consumers | nothing — can run parallel to 0–4A |
| 5 | `vyapaar-ui/0005` | `vyapaar-ui-app`, `vyapaar-tui`, `vyapaar-ui-core` | everything above |
| 6 | `vyapaar-examples/0001`, `vyapaar-docs/0002` | `vyapaar-examples`, `vyapaar-docs` | triggers satisfied by Layers 1–5 (both implemented) |
| 7 | `vyapaar-data/0002` | `vyapaar-data` | still gated on a concrete filings consumer |
