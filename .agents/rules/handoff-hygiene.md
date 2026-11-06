# Rule: HANDOFF.md Hygiene (binding)

**Status: binding for every orchestrator/parent session and every spawned subagent, in every
repository, across the whole `vyapaar-labs` workspace.**

**Origin**: written 2026-11-06, prompted by `vyapaar-labs/.agents/HANDOFF.md` itself already
showing the exact staleness pattern this rule targets — see §5.

This rule complements `AGENTS.md` §1.2 (Inter-Agent Handoff Protocol), which defines *what* goes
in `HANDOFF.md` (Phase/Slice Status, Decisions & Discoveries, Immediate Next Step, Operating
Invariants). This rule is about *keeping it current and short* once it exists.

## 1. Where HANDOFF.md lives, and who updates it

- Every repo actively being worked on maintains `.agents/HANDOFF.md`, created lazily on first
  need — like `docs/gaps/`, not pre-scaffolded into every repo up front.
- A **submodule's own** `HANDOFF.md` tracks that submodule's own in-flight slice/batch.
- The **`vyapaar-labs` root's** `HANDOFF.md` tracks state that spans repo boundaries: which
  tiers/repos are mid-migration, cross-cutting initiatives, the current "where are we in the
  bottom-up build order" picture. It summarizes and points at a submodule's own `HANDOFF.md`
  rather than duplicating that detail.
- Update it at the end of any turn/session that changes what's true about any of the four
  sections above — same discipline as `.agents/rules/gap-tracking.md`'s "file it in the same
  change," not as a deferred follow-up.

## 2. Trim as part of the same edit that makes something stale

Don't wait for a separate cleanup pass. When any of the following becomes true, remove the
corresponding content from `HANDOFF.md` in that same edit:

- **A problem/issue noted is no longer true, no longer existing, or no longer reproducible.**
  Remove it. HANDOFF.md reflects current reality, not history — the fix itself is already
  permanent in git history and commit messages, so HANDOFF.md doesn't need to remember it too.
- **A gap noted in HANDOFF.md has since been implemented/closed.** Remove the HANDOFF.md mention.
  The authoritative, permanent record of a gap's lifecycle is its own `docs/gaps/XXXX-*.md`
  (flip `Status` to closed, link the closing commit/PR there, per `.agents/rules/gap-tracking.md`)
  — HANDOFF.md should never be the only place a gap is tracked, and dropping a closed gap from it
  loses nothing.
- **A report of a specific run/build/test pass is superseded by a newer run.** Remove the old
  report; keep only the most recent one, and only while it's still relevant to the current
  "Immediate Next Step." HANDOFF.md is not a build log or a changelog — it should always read as
  "here's where things stand right now," not an append-only history of every run that ever
  happened.

## 3. When growth itself is the signal

If `HANDOFF.md` grows past the point a new reader can scan it in under a minute — a gut-check,
not a hard line count — that's itself a trigger for a dedicated trim pass even if no single entry
has gone stale yet: fold several completed, superseded slices into one short line each (milestone
+ a pointer to the commit/PR that did it), rather than keeping every historical slice's full
table forever.

## 4. What belongs vs. what doesn't

HANDOFF.md is forward-looking, current-state scratch memory for picking up a paused task — not a
permanent record. Permanent records live elsewhere and get cited, not duplicated into it:

| Kind of content | Permanent home | HANDOFF.md should... |
|---|---|---|
| Closed gap | `docs/gaps/XXXX-*.md` (`Status: closed`) | not mention it once closed |
| Resolved bug / completed slice | commit message + git history | collapse to one line + commit pointer, then eventually drop |
| Past run/build/test report | ephemeral — CI logs if needed again | keep only the latest, drop once superseded |

## 5. Worked example (from this workspace)

As of 2026-11-06, `vyapaar-labs/.agents/HANDOFF.md` is itself a live example of what this rule
asks agents to clean up: it carries a full "Final Gate Report" and "Phase / Slice Status" table
for Tier 0 (`vyapaar-core`) in complete detail, even though the file's own top Status line already
says Tier 4 is green and Tier 5A is next. By this rule's own §2 criterion, Tier 0's gate report
and slice table are stale, superseded status snapshots. The next session that touches this file
should fold Tiers 0–3's detail down to one line each (milestone + commit/PR pointer) before
adding Tier 4/5 detail, rather than letting every tier's full report stack up indefinitely.

## 6. Enforcement

Checked the same way `.agents/rules/gap-tracking.md` is checked: a non-trivial implementation
task's review pass includes a quick HANDOFF.md read — if a Phase/Slice entry, a noted issue, or a
run report no longer matches current reality, trim it in that same change rather than leaving it
for later.
