# Rule: Plan & Gap Tracking (binding)

**Status: binding for every orchestrator/parent session and every spawned subagent, in every
repository, across the whole `vyapaar-labs` workspace.**

## 1. Plans vs. Gaps Definitions

- **Gap** (`docs/gaps/XXXX-short-slug.md`): An individual missing feature, stub, mock, or hardcoded
  workaround representing a single focused capability or endpoint.
- **Plan** (`docs/plans/XXXX-short-slug.md`): A collection of gaps or a multi-phase architectural
  feature roadmap encompassing multiple related capabilities or subsystems.

## 2. The Implementation Rule: Stubbing and Upstream Filing

Whenever implementing a plan or gap:
1. **File in the respective provider repo**: If any hardcoded, stubbed, mock, or sample data is used
   because real functionality is missing, not yet wired up, unverified, or out of scope for the current
   pass, **add a `docs/{plans,gaps}/XXXX-*.md` style document in the respective repository which is
   supposed to provide the functionality** (the upstream/owning repo).
   - Use `docs/gaps/XXXX-*.md` for an individual feature or endpoint.
   - Use `docs/plans/XXXX-*.md` when the missing functionality represents a collection of gaps or multi-step subsystem.
2. **Cite the dependency in the consuming repo**: Any change that depends on, works around, or is
   temporarily stubbed against an existing or newly filed gap/plan must cite it:
   - Add a code comment at the workaround pointing directly to the gap/plan (e.g. `// stand-in for vyapaar-core/docs/gaps/0001-quant-transforms.md`).
   - Cite the gap/plan number in the commit message.
   - Never implement an uncited workaround or leave stubbed/sample data silent.

## 3. Numbering and Entry Templates

- **Numbering**: Per-repo, sequential (`0001`, `0002`, ...), never reused even if an earlier item is closed.
- **Index files**:
  - Every repo with gaps maintains `docs/gaps/README.md` as its index.
  - Every repo with plans maintains `docs/plans/README.md` as its index.
- **Gap Entry Template** (`docs/gaps/XXXX-short-slug.md`):
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
- **Plan Entry Template** (`docs/plans/XXXX-short-slug.md`):
  ```markdown
  # XXXX — Short title

  **Status**: Proposed | Ready for Implementation | Implemented (link closing commit/PR)

  ## 0. Executive Summary & Objective
  ...

  ## 1. Context & Gaps Covered
  ...

  ## 2. Component Specifications & Phases
  ...
  ```

## 4. Lifecycle & Cleanup of Implemented Plans and Gaps

When a plan or gap is implemented:
1. **Cleanup the document**: Once an implementation lands and is verified (tests pass, clean lint/check),
   remove the completed `docs/{plans,gaps}/XXXX-*.md` document from the active `docs/plans/` or `docs/gaps/` directory.
   The git history and the index are the permanent record of closed items.
2. **Update the index**: Move or record the item under the "Implemented plans" or "Closed gaps" section
   in that repo's `docs/plans/README.md` or `docs/gaps/README.md` (recording number, title, area, and closing commit/PR)
   without dangling links to deleted files.
3. **Update referencing indices**: Update any workspace-level roadmap or build order (such as
   `docs/future-work-bottoms-up-build-order.md` or `HANDOFF.md`) referencing that plan or gap.

## 5. Identifying Upstream Provider Repositories

In this multi-repo workspace (`vyapaar-labs/` submodules), a stub's root cause frequently lives in a
different repository than where the symptom appears (e.g., a UI component needing an endpoint in
`vyapaar-runtime`, an indicator calculation needing math in `vyapaar-core`, or a broker feed needing an adapter
in `vyapaar-adapters`).
1. **Diagnose root cause**: Identify the actual repo responsible for providing the functionality.
2. **File in the provider repo**: Add the gap or plan document directly in that respective provider repo's
   `docs/{plans,gaps}/` directory, and update that repo's `README.md` index.
3. **Reference from consumer**: In the consuming repo where the stub is placed, add the citation comment
   naming the provider repo and gap/plan path.

## 6. Enforcement

- During review passes, inspect diffs for `TODO`, `mock`, `stub`, or hardcoded/sample data.
- Ensure every stub has a corresponding gap or plan doc filed in the respective provider repo, cited in code and commit.
- Confirm that implemented plans/gaps are cleaned up from active directories and recorded in the appropriate index tables.
