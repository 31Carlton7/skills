---
name: deslop
description: De-slop a diff or codebase before review — strip AI-authored tells (narration comments, hand-rolled stdlib, incohesive structure), audit what is actually necessary, and verify every claim against the real code. Use before opening a PR, when a reviewer calls code AI-generated or sloppy, when asked to audit or clean up a diff, or as a final pass after any multi-file change.
---

# De-slop: make generated code indistinguishable from a careful human's

Slop is not a style problem, it is a trust problem. Reviewers who spot one
tell stop reading the code and start hunting for more. The fix is never
cosmetic-only: every pass below verifies necessity, not just appearance.

Work from the actual diff, never from memory of what you wrote. If the work
spans branches, audit each branch's diff against its merge base.

## Pass 0 — author small, justify every line (prevention beats cleanup)

Slop is cheapest to remove before it exists. When building:

- **Build piece by piece.** Start with the smallest change that does one
  thing; get it correct and idiomatic before adding the next piece. A large
  diff written in one shot always accretes slop; N small increments, each
  reviewed against this skill, do not. This also produces small PRs, which
  reviewers consistently trust and approve faster than one big one.
- **Interrogate every line at creation time**: why does this line exist? Why
  is this a new function instead of a call to an existing one? Why a new
  file? If the answer is "the generation flowed that way", delete or fold it.
  Every addition needs a reason you could state out loud in review.
- **Do not overcomplicate.** The obvious 5-line version beats the abstracted
  25-line version until a second caller exists. No speculative parameters,
  no "for future flexibility", no wrapper types around one value.
- **Do not recreate the wheel** — at authoring time, not just in cleanup:
  before writing any utility, grep the repo for an existing helper and check
  the dependency tree for a package that owns the problem (see Pass 2).
- **Match the neighborhood before writing.** Read the adjacent files first;
  adopt their naming, error handling, and test harness so the new code reads
  like it was always there.

If the task cannot be built piece by piece (a large port, a vendored
contract), say so and compensate with a stricter Pass 1–5 audit before
anyone else sees it.

## Pass 1 — comments

The single biggest tell. Apply one rule: **a comment must state a constraint
the code cannot show.** Everything else gets deleted.

Delete on sight:
- Narration: `// loop over the entries`, `// call the helper`, `// return the result`
- Restating the code or its own doc header a second time in the body
- Reviewer-talk: `// this is safe because we checked above`, `// note that...`
  — that is you defending the diff, not informing the next reader
- References to the PR, the review, the conversation, or "recently changed"
- Comments explaining why the change is correct (belongs in the PR body)
- Section banners (`// ---- helpers ----`) in files under ~300 lines

Keep (these are load-bearing):
- Wire-format or protocol constraints, especially reverse-engineered ones with
  no public spec: field X must be present even when null; client Y rejects the
  whole payload if Z is missing; cite the upstream source file
- Why-not comments: why the obvious approach was rejected, what breaks
- Platform facts a reader will trip on: this env var is a unix convention;
  this API silently no-ops on Windows
- Security/data-safety invariants: never cache the raw record, it embeds secrets
- Deliberate policy pins that contradict upstream defaults, with the lift condition

Density heuristic, not a rule: for glue/CRUD code, more than ~1 comment line
per 15 added lines deserves a second look. For undocumented-protocol code,
high density can be correct — the comments ARE the spec. Judge each comment
by the keep/delete lists, never by count alone.

Doc headers: 4–8 lines of pure constraints. If a header is a paragraph
narrating what the module does step by step, cut it to what the filename and
exports cannot already say.

## Pass 2 — hand-rolled code that a dependency or stdlib already provides

The second-biggest tell: reimplementing `uuid`, hashing, semver parsing, glob
matching, date math, deep merge.

Procedure:
1. Check what the package already depends on (read package.json, not memory).
   Prefer an existing dep or the runtime stdlib over adding anything.
2. If a new dep is warranted, pick the boring battle-tested one.
3. Before swapping an existing hand-rolled implementation, prove equivalence
   empirically — run both against the same inputs and compare outputs.
   Deterministic-ID and hashing code especially: a swap that changes outputs
   silently breaks idempotency for existing users.
4. If keeping the hand-rolled version is genuinely right (avoids a dep for 10
   lines), expect the reviewer question and decide whether the argument is
   worth more than the dependency. Usually it is not: boring wins review.
5. Exception: code that is already stdlib composition (createHash + pipeline)
   is not hand-rolled. Say so if asked; do not wrap it further.

## Pass 3 — cohesion and necessity

Slop accretes: each edit adds without consolidating. Hunt for:

- **Repeated condition expressions** → extract once, name by meaning
  (`noConfigChanges`, not `check1`)
- **The same literal in N files** → one shared constant in the module that
  owns the concept; adopters import it
- **Local re-implementations of repo helpers** → grep for an existing helper
  before keeping a private copy (`pathExists`, output/format utilities,
  error helpers). Delete the local copy, import the shared one.
- **Dead code**: for every helper/type/export in the diff, find a consumer.
  No consumer → delete now, not "for later".
- **Call sites hand-rolling what a helper owns** (spacing, quoting, id
  generation) → move the behavior into the helper, thin the call sites
- **Same fact stated twice** (doc header + inline comment) → keep one
- **Functions that return tuples of loosely-related values** → often a sign
  two responsibilities got fused; split or document the contract

Then check repo-fit: read neighboring files and match their idiom, naming,
error style, and test patterns. Code that ignores house style reads generated
even when correct.

## Pass 4 — tests

- Tests must pin behavior, not the bug. If an assertion encodes the wrong
  value "because that is what the code does", fix both.
- Mirror the suite's existing harness and helpers; do not invent a parallel
  mock style in the same file.
- Every platform-specific skip carries a one-line reason.
- Test names describe the scenario, not the implementation.
- When you change output shape, add a negative assertion for the removed form.

## Pass 5 — tooling parity, then verify

- Use the repo's pinned formatter/linter version (read package.json — running
  a different major version locally lets CI-only failures through).
- Run the tests the diff touches at every layer of a stacked change, not just
  the tip.
- Re-audit the final diff once more after all edits: `git diff` and read every
  remaining comment line aloud against Pass 1. Density check:
  `git diff | grep -cE '^\+\s*(//|\*)'` vs total added lines.
- Commit messages: explain why, in prose, like a person. No bullet-list
  changelogs for a 3-line commit, no "enhanced/improved/robust".

## Reporting

When asked "is this de-slopped": audit the live diff and answer with evidence
(density numbers, what was deleted, what was deliberately kept and why), never
"yes" from memory. If something was kept that a reviewer might flag — say a
high-density protocol file — name it proactively and give the defense in one
sentence.

When a reviewer calls something slop: concede the pattern before defending
any instance. Fix the category everywhere, including files they did not flag
(and the ones they praised). Applying the standard as a discipline, not as
damage control on flagged lines, is what rebuilds trust.
