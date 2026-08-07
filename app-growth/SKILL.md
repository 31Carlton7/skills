---
name: app-growth
description: Use when ideating, building, launching, or growing a consumer mobile app — picking an app idea, designing the hero feature or demo screen, writing onboarding flows, setting subscription pricing or paywalls, planning influencer/UGC outreach and creator deals, running Meta/TikTok ads, planning a launch, or diagnosing weak conversion, ARPU, or retention.
---

# Consumer App Growth

Distilled from two operator playbooks:
- George's "0 to $10K/mo in under 30 days" — idea selection, the gotcha moment, onboarding, influencer partnerships ($300K+ across Wrestle AI and others)
- Kyan's "$0 to $16K in 31 days" — one-format UGC spam, paywall testing, paid ads

(The full articles aren't republished here since they're the authors' own writing — this file is the distillation.)

## The three pillars (in priority order)

1. **Idea** — marketing only ever takes you as far as the idea allows. George's proof: same founder, same month, same effort — Wrestle AI did 1M views → $17K; a generic AI dating app did 1.8M views → $35. Distribution distributes the idea; a weak idea just fails faster in front of more people.
2. **Product** — must deliver the promise the moment someone opens it.
3. **Distribution** — where most of the work lives. $10K/mo = $333/day.

## Idea selection

- Solve a problem you personally have — you become your own ideal customer, and belief is a negotiating asset with creators.
- The problem must be **frequent** (daily/weekly), **emotionally irritating**, and shared by a large group even if the niche looks small.
- Follow what people **do**, not what they say they want (behavioral truth over verbal claims).
- Niche first, expand later (Facebook = Harvard, Amazon = books).
- Steal proven mechanics across categories: Duolingo streaks → fitness, Spotify Wrapped → any personal stats, Tinder swipes → any decision, seasonal progression → any improvement loop.
- **Purple Cow test**: it must visually stand out the instant it hits a feed. If the product isn't remarkable, the marketing has to be — a much harder game.
- **Reverse-engineer the promo before building**: scroll TikTok/IG as your target customer and ask of every video — who watches this, what problem does this audience have, and how could this creator show my app for 5 seconds without it feeling like an ad? Build the product to fit that video. Side effect: the tuned feed becomes your creator lead list.

## The gotcha moment / viral screen

The single most important asset. One feature, explainable in one sentence, that a viewer understands in 5 seconds with no words — ideally delivering personalized feedback you can't get elsewhere (Cal AI: photo → calories; Wrestle AI: upload match → what you did wrong). Spend ~half of build time here; push it in ~90% of promos (rotate to a secondary feature only when a creator's audience saturates).

Kyan's screen-level version — the **viral screen** must be: visually dense but instantly decipherable, tied to a recognizable trigger (songs/faces/insecurities people know), screen-recordable in under 3 seconds, and different from competitors' homepages. If the main screen is a settings page, there is no ad asset yet.

## Build

- Vibe-code it; the build is not the bottleneck (both shipped in days–2 weeks, no hand-written code). "Slop" is underprompting — prompt page by page until every screen works and looks exactly as imagined; never move past a broken page.
- Order: looks first, then functionality; ~14 days core + branding, a few days on onboarding, then payments/backend (RevenueCat or Superwall for paywall, Supabase backend, cheap public APIs for data).
- **Mom test**: a non-technical person must understand and use the app with zero explanation. "Too cluttered" is gold feedback — simplify until it passes.
- Design in a share loop ("how could users organically share this?") so not all traffic is paid.
- Past ~$5K/mo, reinvest in real product quality (designers, discipline) — vibe coding validates; quality carries you past the ceiling.

## Onboarding (second most important asset)

Four jobs, in order:
1. **Educate** — 3–5s visuals per major feature; people don't pay for what they don't understand.
2. **Personalize** — name, guiding questions that steer them to their own need, then show two roadmaps: their journey with vs. without the app.
3. **Sunk cost** — enough questions that they feel invested, not so many they bounce.
4. **FOMO** — run the gotcha moment right before the paywall and withhold the result ("unlock your rating now"). This converts far better than a cold paywall.

Also: rate-the-app screen placed before the paywall (drove Wrestle AI to 4.8★); push sign-in as late as possible; steal structure from Cal AI / Opal / Quittr onboardings.

## Pricing and paywall

- Default: $9.99/mo, $59.99/yr, 3-day trial **on the yearly only** — funnels users to annual, collecting ~$60 up front (cash flow is what lets you scale spend).
- With direct competitors: copy their pricing. Otherwise intuition, then test.
- Test like Kyan: 3+ paywall variants live simultaneously (yearly/monthly/weekly × trial/no-trial × price points) via Superwall; the right price is a moving target. Never-touched pricing leaves 20–30% of revenue on the table.
- Always run a **one-time discount paywall** shown only when the user closes the first paywall — pure saved revenue.

## Distribution

**Brand Instagram page** — dual purpose: sales funnel (curious viewers binge your pinned demos, arrive at the App Store pre-sold) and creator credibility (a page with followers, verification, and collab posts with every creator you work with is the difference between $2 CPM and 10× that).

**Finding creators — engineer the feed**: fresh account, behave exactly like your ideal customer until the algorithm serves only relevant creators; prospecting becomes scroll → outreach. Followers don't matter; views and engagement do. Green flags: 25K+ avg views, stable 15K floor, multi-platform, distinct style, real comment community. Red flags: wildly inconsistent views, trend-hoppers, all-emoji comments, views without comments. Also: poach competitors' long-running creators — sustained payment means the deal is profitable.

**Outreach**: volume game — 100 DMs/day, or a VA (~$800/mo) running a simple SOP. DM formula: "Paid promo for [handle]?" + one sentence on the app + invitation. Nothing else. Every message pushes toward a phone call; never negotiate price in DMs, never drop a number first.

**Closing (George's influencer deals)**: open warm and hyper-specific about their content; explain the natural integration; ask "what do you feel is a reasonable rate?"; offer $2–3 CPM flat with a low minimum-view guarantee, 20–50% up front. If they push back, reframe as a CPM bet-on-yourself deal with a per-video cap. Track views 7 days max, pay weekly, then silence — you are the buyer. Objection counters: "Big brand paid me more" → "Are you still working with them?"; "ads hurt my engagement" → that's exactly why it's a subtle integration, not an ad. Always pitch long-term partnership; invest in the relationship (it earns the homie discount).

**UGC machine (Kyan's model)**: find an app targeting your audience already spamming one format with multiple creators — that's a proven system; copy it. Hire 2–3 small creators (1K–20K followers, age 17–21, no rate card) at $400–600/mo for 40–45 videos in ONE fixed format. Expect duds; cut any creator whose videos don't move after a few weeks — you're testing creators and captions, not formats.

**The 15–25s video format**: 0–3s creator with shocked face + niche prop + Snapchat-style comment-bait caption, known song, no talking → camera flip → 4–15s app demo (cut all loading/white space) → end with **no CTA in the video**; the CTA is a pinned comment: "the app is [NAME] btw !!" Post identical video to TikTok + Reels (+ FB/YouTube — free extra distribution). Reels often wins volume; TikTok converts better per view. No voiceover, no screen-recording-only videos.

**Creatives with influencers**: the influencer is the hero, the app is a tool in their hand. Study their last 20 posts, use their best-performing format (day-in-the-life, routine, educational, skit, before/after), keep their voice; the app is a moment, not the topic.

**Meme pages**: repost best content, ≤$50/post, target $0.50–1 CPM. **Organic**: validates the gotcha moment; "comment BETA for early access" builds a waitlist and proves pull.

**Paid ads**: recycle organic winners as ads the moment they cross a view threshold. Optimize for **In-App Purchase / Trial Start, never Install** (cheap installs don't convert; CPI ≠ ROI — the only math is CPA < LTV). Scale winning creatives +20–30% budget every 3 days. Mine the Meta Ads Library: competitor ads with high impressions and long spend are proven winners — have a creator remake them one-to-one. Influencers 10× small budgets; ads 2–3× at much larger scale.

## After the post, and launch

- Plant natural comments ("wait what app is that?"); comment from the brand account to turn every comment section into a second funnel. A deal should be profitable within 1–3 days — decide fast if a creator is a keeper.
- Launch option: pre-orders hyped by a launch creator all week convert at once on day one and spike the charts (Wrestle AI: 4,000 pre-orders → #18 on the App Store). Launches break — push through anyway.

## Metrics (once ≥100 downloads/day)

- **Conversion**: find the exact drop-off screen in onboarding/paywall; A/B test onboarding length and pricing.
- **ARPU**: target ≥$2 in month one (low-intent UGC volume lowers it; explanatory influencer content raises it).
- **Retention**: bad retention almost always means the app isn't useful enough yet. The formula: **the viral feature acquires, boring useful features retain** — Wrestle AI halved churn by adding a calorie tracker. Layer in everyday utility after the hook works.

## Common mistakes

- Distribution-first thinking: no amount of reach saves an idea people have already scrolled past a thousand times.
- Changing the video format every post "to see what works" — vary creators and captions, hold the format.
- Optimizing ads for installs because CPI looks cheap.
- Showing secondary features while the gotcha moment still has room to run.
- Long feature-list DMs, negotiating in text, or naming a price first.
- Shipping one price and never touching it again.
- Falling in love with an underperforming creator instead of cutting fast.
