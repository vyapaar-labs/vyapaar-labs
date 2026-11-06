# Rule: Gap Tracking (binding)

**Status: binding for every orchestrator/parent session and every spawned subagent, in every
repository, across the whole `vyapaar-labs` workspace.**

**Origin**: first established in `vyapaar-ui-web` (2026-11-06) while scaffolding that repo —
8 gaps filed in its `docs/gaps/`, including one (`0003-vyapaar-core-wasm32-uuid-getrandom.md`)
whose root cause lives in a different repo (`vyapaar-core`) than the one the stub was filed in.
That repo's `docs/gaps/` is the reference implementation of this rule; read it if an example helps.

## 1. The rule

Whenever an agent stubs, mocks, hardcodes, or works around something **because a real
dependency isn't available, wired up, verified, or working yet**, it files
`docs/gaps/XXXX-short-slug.md` in the repo where the stub lives, **in the same change** — never
as a follow-up, never left silent. "Dependency" is broad: a backend endpoint that isn't running,
an API whose response shape hasn't been verified, a crate that doesn't build for a target yet, a
design decision deferred, a feature deliberately out of scope for this pass.

A repo's `docs/gaps/` is created lazily, on first use — not pre-scaffolded into every repo in the
workspace up front.

## 2. Numbering, index, and entry template

- Numbering is **per-repo**, sequential: `0001`, `0002`, ... Never reuse a number, even if an
  earlier gap closes.
- Every repo with a `docs/gaps/` directory keeps `docs/gaps/README.md` as the index: one row per
  gap (`# | Title | Area`), appended to, never reordered.
- Entry template (every gap doc, no exceptions):
  ```markdown
  # XXXX — Short title

  **Status**: open | closed (link the closing commit/PR)

  ## What's stubbed or hardcoded
  ...

  ## Why
  ...

  ## How to close it
  ...
  ```

## 3. Identifying gaps that actually live in another repo

This is a multi-repo workspace (submodules under `vyapaar-labs/`), so a stub's **root cause**
often isn't in the repo where the symptom shows up — e.g. a build failure in a consuming crate
caused by a missing feature flag in `vyapaar-core`, or a UI screen that can't go live because the
backend endpoint it needs doesn't exist yet in `vyapaar-runtime`. When filing a gap:

1. **Diagnose the root cause before filing**, not just the symptom. Name the actual repo and
   path responsible (e.g. "`vyapaar-core`'s `Cargo.toml` `uuid` dependency, not this crate").
2. **File the gap in the consuming repo** (where the stub/workaround actually lives) — not in the
   dependency repo, unless this session is also explicitly scoped to work in that dependency repo.
3. **Never silently patch a repo outside the current task's scope** to close someone else's gap.
   If the fix belongs in `vyapaar-core` but the current task is in `vyapaar-ui-web`, document the
   gap and the two remediation paths (upstream fix vs. local workaround) — do not reach across
   the repo boundary uninvited. This mirrors the global "stay within the current working
   directory" rule: crossing into another repo to investigate root cause for the gap doc is fine;
   editing it without being asked is not.
4. **Cross-repo visibility**: if this session is *also* working in the dependency repo (or is
   explicitly asked to), it may add a short pointer entry there too, so the gap is discoverable
   from either side. Otherwise, naming the dependency repo/path clearly inside the gap doc is
   sufficient — don't block on getting write access to a repo nobody asked you to touch.

## 4. Citing the dependency when implementing

Whenever a task's implementation **depends on, works around, or is blocked by** something already
tracked as a gap — in this repo or another — the implementing change must **cite it**, not
silently build on top of it:

- A short code comment at the exact point the workaround lives, naming the gap file
  (e.g. `// stand-in for docs/gaps/0006-screener-indicator-math-in-ts-not-wasm.md`).
- The commit message for that change names the gap number(s) it touches or depends on.
- If the new work's own stub is *caused by* an existing gap elsewhere (rather than being a new,
  independent gap), its own gap doc's "Why" section names and links the upstream gap instead of
  re-explaining the same root cause from scratch.

Never implement around a known gap without the citation back to it — an uncited workaround is
indistinguishable from an agent that didn't know the gap existed.

## 5. Enforcement

- Checked the same way `.agents/rules/subagent-discipline.md` is checked: a non-trivial
  implementation task's review pass includes a gap-doc check — grep the diff for
  `TODO`/`mock`/`stub`/hardcoded literals and confirm each hit either needs no gap (trivially
  obvious, e.g. placeholder copy) or has one, with a citation if it depends on an existing gap.
- A subagent dispatched to implement something that touches a known gap is told the gap's number
  and path directly in its prompt (per `.agents/rules/no-recon.md` — this is orchestrator-supplied
  context, not something the subagent should discover on its own).
