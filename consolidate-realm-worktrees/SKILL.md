---
name: consolidate-realm-worktrees
description: Safely consolidate all committed and uncommitted work across Realm's Git worktrees into main, validate the combined tree, and restart the primary-checkout development app as one clean instance. Use when asked to consolidate, collect, merge, land, or bring together Realm worktree changes; clean up divergent local feature work; update main with all local work; or restart/reload Realm after integrating local branches.
---

# Consolidate Realm Worktrees

Preserve every local change, produce one validated history containing every local branch, fast-forward `main`, and restart the app from the primary checkout.

## Inventory before mutation

1. Work from a non-primary worktree until the final fast-forward.
2. Run `bash scripts/inventory.sh <any-realm-worktree>` and inspect every listed worktree.
3. Confirm the primary checkout is clean. Do not edit it while its dev app is running.
4. Inspect every dirty and untracked file. Treat it as user-owned. Preserve suspicious artifacts in a separate commit and report them; never silently discard them.
5. Identify the branch containing the most other branches with `git branch --merged <candidate>`. Prefer an existing integration branch when it already contains the feature branches.

Do not push, delete branches, or remove worktrees unless the user separately asks.

## Checkpoint dirty worktrees

For each dirty worktree:

1. Inspect its diff and infer coherent commit boundaries.
2. Run the required gates before committing:

   ```bash
   SHELL=/bin/bash pnpm vitest run
   pnpm -r typecheck
   pnpm build
   ```

3. If a load-sensitive test fails, rerun that file in isolation. If it passes and a later full run still starves it, rerun the full suite with reduced concurrency, for example `SHELL=/bin/bash pnpm vitest run --maxWorkers=50%`. A full run must finish green.
4. Stage explicit paths only. Never use `git add -A`, `git add .`, or another broad sweep in a shared worktree.
5. Commit before merging or mutation-testing. Keep unrelated artifacts in separate commits.
6. Re-inventory after each checkpoint in case another session changed a worktree.

## Build the aggregate

1. Use the most complete clean non-primary branch as the aggregate, or create a dedicated integration worktree if no existing branch is suitable.
2. Merge branches not already contained by the aggregate with `git merge --no-ff <branch>`.
3. Resolve conflicts by composing both behaviors. Never resolve a conflicted file wholesale with `--ours` or `--theirs` without first proving the discarded side is redundant.
4. After conflict resolution, run the full test, typecheck, and build gates before creating the merge commit.
5. Verify completeness with:

   ```bash
   git branch --no-merged HEAD
   ```

   The result must contain no local feature or integration branch intended for consolidation.

6. Confirm all worktrees are clean. Do not mistake generated ignored files for tracked changes.

## Advance main and restart Realm

1. Locate dev supervisors using the primary checkout path in `ps`. Target only `pnpm dev` processes rooted in that checkout; do not kill packaged Realm, agent sessions, or unrelated Node processes.
2. Stop every duplicate primary-checkout dev supervisor and wait for its process tree to exit.
3. In the clean primary checkout, run `git merge --ff-only <aggregate>`. Refuse a non-fast-forward update and investigate instead of rewriting `main`.
4. Run `pnpm install --frozen-lockfile` when the lockfile or workspace packages changed.
5. Start exactly one persistent `pnpm dev` process from the primary checkout.
6. Verify the renderer URL appears, Electron starts, the server watcher is active, and only one primary dev supervisor remains.
7. Report the final `main` commit, branches covered, validation counts, any isolated/reduced-concurrency retry, retained artifacts, and app health.

## Safety invariants

- Never point tests or manual servers at real `~/Realm`; use a scratch `REALM_HOME` for additional live checks.
- Never copy `~/Realm/realm.db` directly; use SQLite `VACUUM INTO` if a database snapshot is needed.
- Never force-update `main` or destroy a dirty worktree.
- Never use `git checkout --`, `git reset --hard`, or worktree removal as part of consolidation.
- Preserve local commits even when their branch is already merged; consolidation is about reachability, not branch deletion.
