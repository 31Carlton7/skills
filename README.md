# skills

Agent skills I actually use. Each skill is a folder with a `SKILL.md` that
teaches Claude (or any agent that reads skills) how to do one thing well —
loaded on demand, so it costs nothing until it's relevant.

## The skills

| Skill | What it does |
|---|---|
| [`deslop`](deslop/SKILL.md) | De-slop a diff before review — strip AI-authored tells (narration comments, hand-rolled stdlib, dead helpers), audit what's actually necessary, and verify every claim against the real diff. Run it before opening a PR. |
| [`swiftui`](swiftui/SKILL.md) | The SwiftUI mental model (identity, lifetime, dependencies), performance rules for views/List/Table, and the iOS 26 / macOS Tahoe Liquid Glass APIs — distilled from three WWDC sessions. |
| [`app-growth`](app-growth/SKILL.md) | The consumer-app playbook — idea selection, the gotcha moment, onboarding psychology, paywall testing, influencer/UGC distribution, and paid ads — distilled from two operators' 0-to-$10K+ playbooks. |
| [`ghostwrite`](ghostwrite/SKILL.md) | Authoring-time standards so a diff reads as yours before it ever needs cleaning — boring techniques over clever ones, domain-real and unambiguous names, instructions followed literally, pre-existing code left alone, and zero AI attribution in the git history. |
| [`ship-feature`](ship-feature/SKILL.md) | The loop for turning a feature request into a merged PR — research the ask (including any screenshot or screen recording) before building, slice it into one PR per shippable change, prove it by driving the real app and re-reading the frames you captured, then stack and land it. |

## Install

**Claude Code** — copy a skill into your personal skills directory:

```bash
git clone https://github.com/31Carlton7/skills.git
cp -r skills/deslop ~/.claude/skills/deslop
cp -r skills/swiftui ~/.claude/skills/swiftui
cp -r skills/ghostwrite ~/.claude/skills/ghostwrite
cp -r skills/ship-feature ~/.claude/skills/ship-feature
```

Claude picks them up automatically and invokes them when the task matches the
skill's description. You can also trigger one explicitly: `/deslop`.

For a single project instead of globally, copy into `.claude/skills/` at the
repo root.

**Other agents** — anything that supports the [Agent Skills](https://agentskills.io)
format (a folder + `SKILL.md` with name/description frontmatter) can use these
as-is.

## Why these exist

- **deslop** — reviewers who spot one AI tell stop reading your code and start
  hunting for more. Slop is a trust problem, not a style problem. This skill
  makes the model interrogate its own diff: every comment, every hand-rolled
  helper, every "for later" export has to justify itself or get deleted.
- **swiftui** — most SwiftUI bugs (state loss, broken animations, slow lists)
  are identity bugs, and most agents write SwiftUI without a mental model of
  identity at all. This gives the model the same foundation Apple's engineers
  teach, plus the new Liquid Glass design APIs that are past most models'
  training data.
- **ghostwrite** — deslop is a cleanup pass; this is the same standard applied while
  the code is being written. It also holds the line on attribution: no
  `Co-Authored-By: Claude`, no "Generated with" footer, nothing in the history that
  says the repo had a second author.

- **ship-feature** — a feature request is under-specified on purpose, and the
  usual failure is fast code against a wrong reading, followed by "should be
  working now". This skill front-loads the research (including treating a
  screenshot or a clip as the spec it actually is) and back-loads the evidence:
  run the real build, capture it, and re-read the capture before claiming
  anything. One PR per shippable change, stacked when they depend on each other.

## License

[MIT](LICENSE)
