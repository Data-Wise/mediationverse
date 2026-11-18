# Plan: sibling packages (probmed, RMediation, medrobust, medsim, missingmed)

Date: 2026-11-18 | Scope: every mediationverse member except medfit (in progress elsewhere).
Method: read-only sweep of each package's `.STATUS`, `DESCRIPTION` and git state, plus the hub manifest. The
`.STATUS` entries run from mid-October to 2026-11-09, so some may have moved since. `gh pr list` returned nothing
for any repo (read as no open PRs, not confirmed). Nothing in the package repos or the hub was changed.

## Main finding

Every CRAN submission is blocked by a **maintainer decision, not by engineering**: a hold, a manuscript, or the
maturity of medfit. This plan therefore covers only work that can start now and treats the holds as gates to watch.

| Package | Version | CRAN gate |
|---|---|---|
| RMediation | 1.11.1 | Hold from 2026-10-13. Lifts when medfit is mature, or when all three manuscripts (`mbco-lrt`, `Missing Effect`, `pmed`) are ready to submit. |
| medrobust | 0.4.4 | Hold until manuscript M2a is submitted. Pre-submit checks are done. |
| probmed | 0.4.1 | Boundary hold, not cleared. |
| missingmed | 0.10.0.9000 | Blocked by the RMediation hold (needs RMediation >= 1.7.1). |
| medsim | 0.6.0.9000 | Not on CRAN; no submission gate recorded. |

## Work that can start now (in order)

1. **probmed: fix the medfit >= 0.10 guard test.** Against r-universe medfit one test fails, because medfit now keeps
   only complete rows. Small and unblocked. The 0.5.0 contract check in mediationverse already passes against it.
   Output: a patch release or a dev fix (owner's call).
2. **medsim: check whether #35 is unblocked.** `.STATUS` says it waited on probmed#32 (a probmed `dev` to `main`
   release). probmed then shipped v0.4.0 and v0.4.1 on 2026-10-21, so this may already be clear. Verify on GitHub
   first.
3. **medsim 0.6.1:** #28 cluster docs, plus #35 if step 2 clears it. #29 stays deferred. Open decision for the
   owner: should r-universe build `dev` or `main`?
4. **missingmed: close out T5.** Still unaccepted: D4 closure, D5 and the checkpoint
   (`docs/REQUEST-p3-ruling-2026-10-26.md`). Needs the owner's rulings, not coding.
5. **probmed: decide what to do with Gaussian candidate d.** It failed the I6 gate on 2026-10-19 and work stopped
   before I7. The exact-Gaussian run passed its original rule. The 2026-10-20 note keeps merge blocked and says to
   investigate; no new run is planned.

## Nothing to do

- **RMediation, medrobust:** on hold, no engineering work pending. Re-check the gate when medfit matures or a
  manuscript is submitted.

## Loose ends noticed

- medsim checkout: on `feature/mbco-mi-default-align` with deleted `inst/doc/getting-started.*` and an untracked
  `tasks/PLAN-research-workflow-enhancements-2026-10-20.md` (uncommitted work).
- missingmed checkout: on `feature/lavaan-mbco-medfit`, though PR #102 merged on 2026-10-26.
- Hub manifest: `updated:` still reads 2026-06-10 and lists packages without versions (versions live in rforge,
  per the hub policy).

## Out of scope

medfit; any write to a package repo or the hub without a per-repo go-ahead; CRAN submissions (all gated above).
