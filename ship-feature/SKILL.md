---
name: ship-feature
description: Use for any "can you add / fix / change X" request that should end in a merged PR — research the ask (including any screenshot or screen recording) before building, slice it into one PR per shippable change, build it, prove it works by driving the real app end to end and re-reading the screenshots or recorded frames you captured, de-slop the diff, then open the PR (stacked when slices depend on each other) and prepare it for merge. Covers mobile, desktop, web, CLI and library work.
---

# Ship a feature: research it, build it, prove it, land it

A feature request is under-specified on purpose — the person asking already
has the thing in their head and only types the part they think is missing.
The dominant failure is not bad code, it is fast code against a wrong reading.
So the shape of the work is: spend the front of the task collapsing ambiguity,
spend the back of it producing evidence a human can check, and keep the middle
small.

Two rules hold across every phase:

- **Evidence, not assertion.** "It works" is not a claim you get to make from
  the fact that you wrote it, or from a green unit suite. It comes from running
  the real thing and looking at the result. If the result was ugly or the proof
  failed, say that — a reported failure costs one message, a false pass costs
  the user's trust in every pass you ever report.
- **One PR per shippable change.** Never one branch with everything on it. The
  slice list is decided before code is written, not discovered at commit time.

Authoring standards come from [`ghostwrite`](../ghostwrite/SKILL.md) and the
final cleanup from [`deslop`](../deslop/SKILL.md). This skill is the process
around them.

## Phase 0 — read the ask, then size it

Restate the request in your own words in two sentences: what changes for the
person using the product, and where. If you cannot write that sentence, you do
not understand the ask yet — that is a research question, not a build question.

Write a constraint ledger: every explicit requirement, every "don't", every
named file or screen, the platform, and anything the request implies is already
true. Keep it for Phase 6; you will check the diff against it, not against your
memory of intending to satisfy it.

Then size the work, because size decides how much research — not whether to
prove:

| Size | Looks like | Research | Proof | PRs |
|---|---|---|---|---|
| Trivial | typo, copy change, one-line guard | skim the call site | run it once, capture if visual | 1 |
| Feature | one behavior, a few files | Phase 1 fan-out | full Phase 5 | 1 |
| Multi | "and also", several screens, a migration + its UI | Phase 1 fan-out per area | full Phase 5 per slice | stacked |

Scaling down is allowed. Skipping proof is not.

## Phase 1 — research before you touch code

Run this as a real research pass, not a grep and a guess. The questions below
are independent, so run them in parallel — in Realm, `agent_start` one
sub-agent per question and `agent_wait` on them; elsewhere, one `Agent` /
`Explore` task each. Never split a chain where step two needs step one's
answer; that is just a slower version of doing it yourself.

1. **Where does this live?** The files that own the behavior, the state that
   drives it, the tests that currently cover it, and the nearest existing
   feature that already does something similar. The answer to "how do I build
   this" is usually "the way the neighbor was built."
2. **What has already been tried?** `git log -S<term>`, closed PRs, TODOs,
   the repo's design docs (`design.md`, `AGENTS.md`, `CLAUDE.md`, ADRs). A
   feature that was removed once was removed for a reason, and a reviewer who
   knows that reason and sees you re-adding it will say so in review.
3. **What is the outside standard?** Only when the feature has one: platform
   guidelines (HIG, Material), the API's real docs, how two or three shipped
   products handle the same interaction. Prefer the primary source over your
   memory of it.

Finish the phase by writing, for yourself, a short understanding: what you now
believe is being asked, the mechanism you will use, and **an explicit list of
what the request did not specify along with the assumption you are making for
each**. If an assumption would change the shape of the work if wrong, put it in
front of the user in one line before you build. Otherwise state it and proceed.

## Phase 2 — an image or a video is a specification

You cannot watch a video and you do not see an image the way the sender did.
Decompose both into things you can actually read, and read them before you
interpret them.

**Video.** Get the shape first, then the frames:

```sh
ffprobe -v error -show_entries format=duration -show_entries stream=r_frame_rate,width,height "$CLIP"
mkdir -p /tmp/beats && ffmpeg -loglevel error -i "$CLIP" -vf fps=2 -q:v 2 /tmp/beats/%03d.png
```

Read the frames **in order** and write a beat sheet — `t=0.0 list at rest`,
`t=1.5 tap on the second row`, `t=1.7 sheet starts`, `t=2.1 sheet overshoots
and settles`. When something changes between two frames, re-sample that window
densely (`-ss 1.4 -t 0.8 -vf fps=20`) and read those. In a bug clip the bug is
almost always in the transition, not the endpoint, and at 2fps you will miss
it and confidently describe the wrong problem.

**Image.** Say what is literally on screen before you say what it means: which
screen, which element, what state. Then crop the region under discussion and
re-read it enlarged — that is the only way to judge spacing, radius, weight or
alignment:

```sh
ffmpeg -loglevel error -i shot.png -vf "crop=W:H:X:Y,scale=iw*4:ih*4:flags=neighbor" /tmp/crop.png
```

If the image is a mock or a "make it look like this", enumerate every
difference from what the build renders today. That list is the spec; the
sentence in the message is just the pointer to it.

**When media and text disagree**, the media usually governs appearance and
behavior, the text governs scope — but say which one you followed. And restate
the media as text in your plan, so the plan can be checked by someone who
doesn't open the file.

## Phase 3 — slice into PRs before writing code

Cut at the seams where a reviewer could stop and the product still works. A
schema change that nothing reads yet is a slice. A screen that uses it is the
next one. Each slice gets, written down, before any of it is built:

- the one sentence a reviewer will read as the PR title,
- the behavior that will be true when it merges,
- **the artifact that will prove it** — "a screenshot of the composer with the
  attachment chip", "a 3s recording of the swipe-to-dismiss", "the CLI run with
  the new flag against a scratch home".

Deciding the proof up front is what stops you from building something you
cannot demonstrate. If you cannot name the artifact, the slice is too abstract
to be one PR.

Dependent slices stack: slice 2 branches off slice 1's branch, not off `main`.
Independent slices both branch off `main` and can land in any order.

## Phase 4 — build the slice

[`ghostwrite`](../ghostwrite/SKILL.md) governs how the code reads. Beyond that:

- One branch per slice, named for the behavior, off the right base.
- Build the smallest working version of the slice first and run it, then add
  the rest. A slice built in one shot is a slice debugged in one shot.
- Tests at the level the repo already tests at, next to the neighbors. They are
  the regression net for later; they are not the proof in Phase 5.
- Never edit a checkout something else is serving — if a dev server is running
  from a tree, work in a different worktree or it will rebuild under you.
- Commit before anything that can revert files (`git checkout --`, mutation
  runs, a long agent). Uncommitted work is not work.

## Phase 5 — prove it end to end, in the real thing

This is the phase that makes the difference, and it is the one most likely to
be quietly skipped. Unit tests passing means the code does what you thought;
this phase asks whether the product does what was asked.

**Rebuild first.** A stale binary is the single most common cause of both a
phantom bug and a phantom pass. Rebuild, then run.

**Drive it the way a user would.** Enter through the real entry point — the
screen, the URL, the command — not through an internal function that skips the
wiring you just wrote. The wiring is the part that breaks.

**Capture.** Static change → screenshot. Anything with motion, gesture,
timing, or more than one step → screen recording. Per-platform commands are in
[`proof-recipes.md`](proof-recipes.md).

**Then re-read your own capture.** This is the step, not a formality:

- Open the PNG, or sample the MOV into frames the way you did in Phase 2, and
  **describe what you actually see before you judge it**. Writing "the sheet is
  at the bottom, the header is clipped by 4px" makes you look; writing "verified
  ✓" does not.
- Check the capture against the beat sheet or the mock delta list from Phase 2,
  item by item.
- Compare against a **control** — the same view before the change, or a region
  the change should not have touched. Absolute checks pass on a half-broken
  screen; deltas do not.
- If motion is the feature, check the frames for the in-between: does it
  overshoot, does it settle, is the first frame already at the end state
  (meaning the animation never ran)?

**Pixels beat the DOM.** Accessibility trees, `elementFromPoint`, and
`getBoundingClientRect` describe the document, not the composite. Video layers,
native subviews and GPU-composited elements routinely paint over things the DOM
says are on top, and every DOM-level assertion passes while the screen is
plainly wrong. If the claim is visual, the evidence is pixels.

**Also prove the negative.** Capture the state that should *not* appear: the
empty list, the error path, the reduced-motion variant, the permission-denied
branch. A feature that only works in the happy case fails in review, not in
your run.

**When the capture shows it is broken**, go back to Phase 4 and capture again.
Never narrate a pass from a capture you did not look at, and never describe an
artifact you did not produce.

## Phase 6 — de-slop and check the ledger

Run [`deslop`](../deslop/SKILL.md) against the real diff (`git diff <base>...`),
not from memory of what you wrote. Then take the Phase 0 constraint ledger and
check each line against that diff. Anything that slipped gets fixed now, and
anything you deliberately did not do gets written down for the PR body.

Gates before the PR: the repo's full test suite, its typecheck, its build,
its linter. All green, all actually run.

## Phase 7 — open the PR

One PR per slice. Body, in this order and no longer than it needs to be:

```
What changes, and why — one paragraph, written for someone who did not read
the request.

## Verification
What was run, on what build, and what was observed. Name the artifacts and
where they are. Be specific: "recorded the swipe on iPhone 16 sim, frames at
0.35s show the overshoot settling in ~120ms; empty-state capture attached."

## Not covered
What was deliberately left out, and anything a reviewer should decide.
```

No per-file changelog — the diff is right there. No "comprehensive", no
"robust", no AI attribution anywhere (see `ghostwrite` Rule 0).

`gh` cannot upload images, so keep artifacts at a stable path, list the paths
in the PR body, and tell the user which ones to drag in if they want them
inline. Describe the artifact precisely enough that the body stands alone
without it.

**Stacked PRs.** Push each branch, then open them parent-first:

```sh
git push -u origin feat/schema && git push -u origin feat/screen
gh pr create --base main        --head feat/schema --title "..." --body-file /tmp/pr1.md
gh pr create --base feat/schema --head feat/screen --title "..." --body-file /tmp/pr2.md
```

Each child's body opens with `Stacked on #<parent> — merge that first.` Its
diff against its own base is the reviewable unit; check it with
`gh pr diff <n>` and make sure it does not contain the parent's changes.

## Phase 8 — prepare the merge, and ask before landing it

Merge gates: CI green on the PR itself, review resolved, and for a stack, every
parent already merged. After each parent lands, rebase the children onto the
updated base and re-run their checks — a stack that was green before its parent
merged is not evidence about the stack after.

Merging is outward-facing and hard to undo. If the user said to merge, merge
once the gates are green and report it. If they did not, stop at "ready to
merge" with the PR links, the gate status, and what merging will do. Never
force-push a shared branch on your own initiative.

After a merge: delete the branch, pull the base, and confirm it still builds.

## Done means

- The two-sentence restatement from Phase 0 is true of the running product.
- Every ledger constraint is satisfied in the diff, or listed as not covered.
- A real run of the real build happened, and its artifact was re-read and
  described — including the negative case.
- `deslop` ran on the final diff; suite, typecheck and build are green.
- One PR per slice, stacked where dependent, each with a verification section
  that names its evidence.
- Nothing was merged that the user did not ask to have merged.
