# Software development lifecycle

How Zaka was actually built, phase by phase. Where a phase was skipped or
done informally, it says so — an honest record is more useful later than a
tidy one.

Every phase links to the issues and commits that carried it.

---

## 1. Requirements

**Done, informally.** No requirements document. Scope was settled by a short
set of decisions up front:

| Decision | Choice | Why |
| --- | --- | --- |
| Scope | Record, list and summarise expenses | Smallest thing that is useful daily |
| Storage | On-device SwiftData | No account, no server, no running costs |
| Currency | South African Rand, fixed | Single-user app in one country |
| Platform | iOS 26 | Liquid Glass does not exist earlier |

Requirements since then have arrived conversationally and been captured as
issues rather than written ahead of time. For a personal app that is a
reasonable trade; on a team it would lose traceability from need to change.

**Gap:** no acceptance criteria were written before building, so "done" was
judged by eye.

## 2. Design

**Partial.** Two kinds of design happened, neither formally:

- **Visual** — logo and splash explored on a design canvas before any code,
  with six directions reviewed and one chosen ([#7](../../issues/7),
  [#8](../../issues/8)).
- **Technical** — decided while building, recorded after the fact in
  [DECISIONS.md](DECISIONS.md).

**Gap:** no architecture diagram, no data model drawn before it was written.
The model is small enough that this cost little, but the category rework
([#13](../../issues/13)) would have been cheaper with a schema sketch —
storing categories as raw strings was the right call and was arrived at by
luck as much as judgement.

## 3. Implementation

**Done.** 33 commits, each a single reviewable unit with a message explaining
*why* rather than what.

Code comments were later stripped at the owner's request, so reasoning now
lives in commit messages and these documents. `git log` is the primary
record; `git show <sha>` recovers the thinking behind any line.

## 4. Testing

**Weakest phase, now partly addressed.**

For most of the build, testing was manual: run on the simulator, drive the UI,
read the database back. That caught real bugs — the comma parsing fault
([#5](../../issues/5)) and the mirrored R ([#9](../../issues/9)) were both
found by looking rather than by a test.

It also *missed* one. The CSV share bug ([#12](../../issues/12)) survived
because the only share target exercised was *Save to Files*, which works from
raw data where the others do not.

Now automated:

**40 tests across two suites.**

`swift test` — pure logic, no simulator needed:

| Area | Coverage |
| --- | --- |
| Amount parsing | Separators, grouping, partial input, rejection |
| EAN-13 barcodes | Check digits, guards, encode/decode round trip |

`xcodebuild test` — needs the app and a simulator:

| Area | Coverage |
| --- | --- |
| Category mapping | Live values, retired values, unknown fallback, uniqueness |
| SwiftData | Round trip through an in-memory store, reads do not rewrite |
| Day grouping | Bucketing, per-day totals, newest first |
| CSV export | Ordering, header, number format, awkward notes, filename |
| Loyalty cards | Symbology detection, acceptance, last four, raw round trip |
| Spend breakdown | Slice grouping, ordering, ties, totals preserved, degenerate input |

Both suites compile the app's own source, so there is no second copy to
drift.

**Gap:** the SwiftUI views themselves have no coverage — no UI tests — and
the camera scanner cannot run in the simulator at all.

## 5. Deployment

**Manual, and constrained by the Apple account.** Builds are signed with a
free personal team, installed over USB with `devicectl`. See
[DEVOPS.md](DEVOPS.md).

Two hard limits, neither solvable in code:

- Provisioning expires every 7 days ([#18](../../issues/18)).
- iCloud sync cannot be signed at all ([#17](../../issues/17)).

## 6. Maintenance

**Active.** Changes arrive as requests, become issues, and close against the
commits that resolve them.

One incident so far: a folder of real expense data was committed to a public
repository ([#15](../../issues/15)). Cause was a blanket `git add -A` with
backups sitting inside the working tree. Partly remediated; the follow-up is
recorded on the issue rather than quietly dropped.

---

## Traceability

Each closed issue carries a comment listing the commits that delivered it, so
the chain runs **issue → commit → code** in both directions:

```bash
gh issue list --repo Jabulile1704/Zaka --state all
gh issue view 5 --repo Jabulile1704/Zaka   # the comma-parsing bug
git show a829019                            # the commit that fixed it
```

## Honest summary

| Phase | State |
| --- | --- |
| Requirements | Informal, captured as issues after the fact |
| Design | Visual yes, technical recorded retrospectively |
| Implementation | Solid, granular history |
| Testing | Partial — pure logic only |
| Deployment | Manual, blocked on a paid Apple account |
| Maintenance | Active, with one security incident logged |
