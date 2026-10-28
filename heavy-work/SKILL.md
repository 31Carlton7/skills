---
name: heavy-work
description: Run builds, test suites, simulators and dev servers frugally on a machine other agents share — check memory pressure first (Realm's `machine_status`, or the OS's own readings), cap test workers when memory is short, never run two full suites at once, reuse and then shut down the simulators you boot, stop the servers and watchers you start, and kill the orphans you leave. Use before any build, full test run, simulator boot or long-running server, whenever the machine is slow, swapping or overloaded, and before saying a task is done.
---

# Heavy work on a shared machine

When several agents work on one Mac, each one behaves as if it had the machine to
itself. Measured on a 24 GB Mac running four agents: each started a full test suite
at the same moment, the load average reached 157–482, 20 GB went to swap, and every
suite took many times longer than it would have alone — including the one that was
the point. Nobody's work was faster for running in parallel.

The fix is not to do less work. It is to look before starting anything heavy, size
it to what the machine has left, and leave nothing running behind you.

## Rule 0 — look before you lift

Before a build, a full test suite, a simulator boot or a dev server:

- **In Realm**, call `machine_status` (the `realm-workspace` group). It answers with
  memory pressure, swap, load, what of Realm's is heavy, which builds and suites are
  already running on the Mac, and how many test workers to use. Follow its advice.
- **Anywhere else**, read the same facts yourself:
  - macOS: `sysctl kern.memorystatus_vm_pressure_level vm.swapusage` (1 is normal,
    2 warn, 4 critical) and `uptime`; `memory_pressure -Q` for the free percentage.
  - Linux: `cat /proc/pressure/memory` (an `avg10` over 10 is pressure), `free -m`,
    `uptime`.
  - What is already running: `pgrep -fl 'vitest|jest|xcodebuild|pytest|cargo (build|test)|gradle'`.

Then decide:

| What you see | What to do |
|---|---|
| Pressure normal | Go. Half the cores is plenty of test workers. |
| Pressure warn, or swapping out steadily | Run only the tests that cover your change, with at most 2 workers (1 on a machine with fewer than 8 cores). |
| Pressure critical | Do not start a build, a full suite or a simulator. Finish or stop what is running, then look again. |
| Load over 1.5× the cores | The CPUs are oversubscribed: wait for running work to finish, or use fewer workers. |
| A full suite or build is already running | Do not start another. Run targeted tests, or wait for it. |

macOS can report "normal" while it pages out to a swap file that only grows. Swap
nearly full, or a compressor holding many gigabytes, means the next big process
will page — treat it as warn.

## Rule 1 — run the smallest test that proves the change

- Run the test files that cover what you changed, by path. The full suite runs once,
  at the end, and only if the task calls for it.
- Cap workers when memory is short:
  - vitest: `--maxWorkers=2`, or `--no-file-parallelism` for one file at a time
  - jest: `-w 2`
  - pytest (xdist): `-n 2`
  - cargo: `-j 2`, and `-- --test-threads=2`
  - gradle: `--max-workers=2`
  - xcodebuild: `-parallel-testing-enabled NO`, one destination
- **Never run two full suites or builds at once on one machine** — not two agents',
  and not two of your own sub-agents'. If you split work across sub-agents, give the
  full-suite run to exactly one of them.
- No watch mode unless someone asked for it. A watcher outlives the task and keeps
  rebuilding for nobody.
- A test failure under load is not evidence. A suite that fails broadly while the
  machine is saturated or the disk is full often passes alone; re-run the failing
  file by itself before debugging it.

## Rule 2 — simulators and emulators

A booted iOS simulator is a whole operating system: measured at about 9 GB of
footprint and 177 processes for one iPhone simulator, most of it compressed or
swapped where `ps` cannot see it.

- Reuse a booted device before booting another: `xcrun simctl list devices booted`.
- Boot one at a time unless the task needs two.
- Remember which ones **you** booted, and shut those down when you are done:
  `xcrun simctl shutdown <udid>`. For an Android emulator you launched:
  `adb -s <serial> emu kill`.
- Never shut down a device you did not boot. A simulator that was already running is
  somebody's Xcode session.
- In Realm, a simulator Realm booted is shut down on its own once nothing has used it
  for its idle window: 30 minutes by default, 10 while memory is short and 5 when it is
  critical — and at once from Settings ▸ RAM's button, for one nobody has touched in
  the last few minutes. That is a backstop, not a reason to leave one running.

## Rule 3 — servers, watchers and background commands

- Start a dev server only when the task needs one running. Note its PID and port as
  you start it.
- Stop it when you no longer need it: `kill <pid>`, or by port:
  `lsof -nP -iTCP:<port> -sTCP:LISTEN -t | xargs kill`.
- Prefer a one-shot build or a single request over a long-running process.
- A command you background keeps your own agent process alive too. In Realm, an idle
  engine is stopped to free its memory. It spares a Claude engine whose Bash tool is
  still running a command it backgrounded, or that set a loop or a cron — but it
  cannot see every engine's background work, so a server you started in the
  background may be stopped with your engine, or may pin it in memory. Stop what you
  start rather than relying on either.

## Rule 4 — clean up what you leave behind

Test runs and killed sessions leave orphans: processes whose parent is gone, adopted
by `launchd` or `init` (parent PID 1).

- After a test run, look for yours:
  `ps -axo pid,ppid,pcpu,etime,command | awk '$2 == 1'` and read the commands.
- A process that ignores SIGTERM needs SIGKILL. The classic one is a test fixture
  like `sh -c "trap '' TERM; while :; do :; done"` — it burns a full core for days
  and is invisible in any memory column.
- **Kill only what you can attribute to your own work**: a command line you ran, your
  working directory, your port, a start time after you began. Never another agent's
  suite, never the user's apps, never a process you merely do not recognise. When in
  doubt, report it instead.

## Rule 5 — measure in the unit that matters

`ps`'s RSS counts only pages in RAM right now, so a process macOS has compressed or
swapped out reads small exactly when it costs the most. Read footprint instead:
Activity Monitor's Memory column, `footprint -p <pid>` (your own processes, no
privileges needed), or `top -l 1 -stats pid,mem` for everything. On Linux,
`/proc/<pid>/status` VmRSS plus VmSwap is the closer number.

## Before saying it's done

1. Every simulator or emulator you booted is shut down, or you say why it is still up.
2. Every server, watcher and backgrounded command you started is stopped.
3. No orphan of yours is left under PID 1.
4. You ran the full suite at most once, and not alongside another.
5. Your report names anything you deliberately left running, and how to stop it.
