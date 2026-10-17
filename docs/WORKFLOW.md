# Branching and pull requests

Zaka was built straight onto `main` — every commit pushed directly, no
branches, no review step. That worked because one person was writing all of
it, but it gives up things worth having: a place to see a change whole before
it lands, CI passing *before* `main` moves, and a written reason for each
change that is not buried in a commit body.

This is the workflow from here on.

---

## The short version

```bash
git switch -c feat/budgets          # branch
# ... work, commit as you go ...
git push -u origin feat/budgets     # push the branch
gh pr create --fill                 # open the PR
# CI runs. Review. Then:
gh pr merge --squash --delete-branch
```

## Branch names

`<type>/<short-description>`, lower case, hyphens.

| Prefix | For |
| --- | --- |
| `feat/` | New capability — `feat/recurring-expenses` |
| `fix/` | Something behaving incorrectly — `fix/comma-decimal-parsing` |
| `docs/` | Documentation only — `docs/branch-and-pr-workflow` |
| `chore/` | Tooling, CI, housekeeping — `chore/bump-deployment-target` |
| `refactor/` | Shape changes with no behaviour change |

Branch per issue, not per day. If a branch is growing a second unrelated
change, that is a second branch.

## Commits

Unchanged from how the project already works, and worth keeping:

- One reviewable unit per commit.
- Subject in the imperative, under about 70 characters.
- The body explains **why**, not what — the diff already says what. This
  matters more here than in most projects, because the code carries no
  comments.
- Reference the issue: `Closes #21` in the final commit, or in the PR body.

## Pull requests

Every change that is not a typo goes through one, even working alone. The
value is not approval — it is the pause to read your own diff as a whole.

CI runs on every pull request, both jobs. **Do not merge red.**

Squash-merge by default, so `main` keeps one commit per change and the branch
history stays private to the branch. Use a merge commit only when the
individual commits genuinely matter to later readers.

Delete the branch on merge. `gh pr merge --squash --delete-branch` does both.

## When to skip the branch

Pushing straight to `main` is defensible for a typo in a document or a
revert of something broken that is actively hurting you. Everything else gets
a branch; the overhead is about ten seconds.

## Worth adding later

**Branch protection on `main`** — require the CI checks to pass and block
direct pushes. Not enabled yet, deliberately: with a single committer it
would mostly get in the way, and a protected `main` cannot be fixed quickly
when something is on fire. Worth turning on the moment a second person
commits, or when the app has real users.

Settings → Branches → Add rule → require status checks `Logic tests` and
`App tests on a simulator`.
