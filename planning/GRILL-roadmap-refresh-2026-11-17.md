# Grill: ecosystem roadmap refresh (2026-11-17)

Target: the mediationverse ecosystem roadmap and the planning roadmaps across packages.
Method: codebase-first read-only sweep of the hub and each package's `.STATUS`, CRAN checked via crandb, then
one question per decision.

## Evidence (read 2026-11-17)

- Hub `docs/ROADMAP.md` says "Last Updated 2026-05-09" and still lists three May PRs as open.
- Package versions in the checkouts: medfit 0.18.0.9000, probmed 0.4.1, RMediation 1.11.1, medrobust 0.4.4,
  medsim 0.6.0.9000, missingmed 0.10.0.9000.
- CRAN (crandb): only medfit 0.3.2 (2026-07-23) and RMediation 1.6.1 (2026-07-21) are published; probmed,
  medrobust, medsim, missingmed and mediationverse are not. This matches mediationverse `.STATUS`.
- Package `.STATUS` files disagree in tone: medfit `cran_state: accepted` (true for 0.3.2, silent about the gap
  to 0.18), probmed `unblocked`, medrobust `hold`.
- The hub repo's checkout sits on `docs/missingmed-0.6.0`, not `main`.

## Decisions (all locked)

1. **Write scope: hub plus mediationverse only.** Package `planning/` directories stay with their owners.
   Rejected: editing all seven package repos (eight PRs, high drift risk).
2. **Hub shape (revised, see 7): manifest facts plus roadmap prose.** First locked as "refresh facts in
   ROADMAP.md", then superseded once the hub's own 2026-10-26 rule surfaced. Rejected: thin pointer page (loses
   the narrative); a drift check script (new tooling not requested).
3. **Source of truth: CRAN and GitHub tags win over `.STATUS`.** `.STATUS` supplies next steps and blockers only;
   stale lines are listed, not copied.
4. **Schedule: gated milestones, no calendar quarters.** Gates in order: probmed submits, medrobust hold lifts,
   medsim, then mediationverse. Rejected: re-slipping to 2027 quarters (depends on a journal decision).
5. **mediationverse next release: candidates with exit criteria, no committed theme.** Record 0.2.0 to 0.4.0 as
   shipped; candidates are more recipe articles, and `mediate()` only if the exit criteria in
   `DESIGN-mediate-pipeline-2026-11-17.md` are met.
6. **Hub edits go through a new worktree off the hub's `main` and a PR.** The hub's checked-out
   `docs/missingmed-0.6.0` is not touched. Rejected: committing on that branch; a patch file only.

7. **Revision of decision 2: follow the hub's own policy.** The hub marked `ROADMAP.md` historical on 2026-10-26 and
   made `ECOSYSTEM-MANIFEST.yaml` the live source, so versions and CRAN state are refreshed in the manifest only,
   and the roadmap carries direction, gates and candidates without version numbers. Rejected: keeping decision 2
   as first locked (contradicts the banner); manifest only (decisions 4 and 5 would have nowhere to land).

## Outcome

Hub PR (mediation-planning) carries the manifest and roadmap edits; this repo carries the ledger. The package
repos' own `planning/` directories were not touched (decision 1).

## Open questions

- Whether the hub's `PROJECT-HUB.md` and `TODOS.md` need the same refresh (not grilled; read them before editing).
- Re-query CRAN and GitHub tags for each package immediately before writing, since facts move.
