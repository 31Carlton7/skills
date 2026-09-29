---
name: app-review
description: Use when an app is heading to the App Store or Google Play and needs a pre-submission audit, when the user asks to "review my app like Apple would", check guideline compliance, diagnose or prevent a rejection, or prepare a submission. Covers iOS App Store Review Guidelines and Google Play policies.
---

# Self App Review — Deep Pre-Submission Audit

## Overview

Act as the app's reviewer before Apple or Google does. Run every static, metadata, privacy, and runtime check a real reviewer (and their automated scanners) would run, produce findings with guideline citations and fixes, and loop until the verdict is GREENLIT.

Reality check to state in every report: no audit can guarantee approval. Review has subjective lanes (4.3 spam, paywall prominence, minimum functionality) and human variance. This skill's goal is: zero findings in the objective lanes, and explicit risk callouts with mitigations in the subjective ones.

Coverage: the references encode ~155 discrete checks (57 Apple, 47 Google Play, 51 field-tested rejection patterns) across 80+ cited guideline sections. Report how many checks ran and how many were N/A for this app, so the user can see coverage, not just findings.

## References (load the ones that apply)

- `references/apple.md` — full Apple checklist: guidelines 1.x-5.x, privacy manifests, nutrition labels, ATT, account deletion, export compliance, age ratings, DSA trader, ASC state
- `references/google-play.md` — Play policy families: console declarations, Data safety form, sensitive permissions, Play Billing, metadata, Families, target API, pre-launch report
- `references/rejection-patterns.md` — real-world rejection lore: review logistics, device-matrix surprises, hidden-feature terminations, paywall traps. ALWAYS load this one; it catches what the official docs undersell

## Severity model (borrowed from greenlight, keep it)

- **CRITICAL** — near-certain rejection (external payment for digital goods, missing ATT with tracking SDK, crash on launch, broken demo account)
- **HIGH** — likely rejection (vague purpose strings, missing restore purchases, dead support URL)
- **WARN** — reviewer-dependent risk (template similarity, paywall prominence, borderline minimum functionality)
- **INFO** — best practice / future deadline

Verdict is three-tier: **NOT VIABLE** (the premise itself fails review — see the gate below) / **NOT READY (N must fix)** / **GREENLIT** (zero CRITICAL/HIGH). Every finding = `{severity, guideline/policy §, what was found, where, concrete fix}`.

## Audit phases (run all that apply; parallelize with subagents for large apps)

### Phase -1 — Premise viability gate (run FIRST, before auditing any detail)

Before checking implementation, judge whether the app's core concept can be approved at all. If it can't, say so plainly, explain why with citations, and propose the nearest viable pivot instead of auditing a doomed app. Premise killers:

- **Banned outright**: porn/hookup (1.1.4), fake-anything apps — fake calls, fake device data, fake trackers, even "for entertainment" (1.1.6), dangerous challenges (1.4.5), DUI checkpoints from non-law-enforcement (1.4.4), media downloaders for YouTube/SoundCloud etc. (5.2.3), on-device crypto mining (2.4.2), app-store-like catalogs (3.2.2), apps that are primarily ads, binary options (Play), encouraging drug/vape/excess-alcohol use (1.4.3)
- **Wrong developer entity — app is fine, the account isn't**: banking/finance/healthcare/gambling/cannabis/crypto-exchange apps need the licensed legal entity's Organization account, not an individual (5.1.1(ix), 3.2.1(viii)); crypto wallets need Organization enrollment (3.1.5); white-label/template apps must ship from the client's own account (4.2.6). Flag early: re-enrollment takes weeks
- **License-gated**: real-money gambling (licensed per territory, geo-restricted, free on store, 5.3), personal loans (APR ≤36%, no ≤60-day terms, 3.2.2(ix)), custodial crypto wallets on Play (government licenses), VPNs (org account + NEVPNManager, 5.4), medical-device claims (regulatory clearance). No license in hand = NOT VIABLE until obtained
- **Sensor/claim impossibilities**: measuring blood pressure/glucose/temperature with phone sensors alone (1.4.1), drug-dosage calculators from non-approved entities (1.4.2), health claims against medical consensus (Play Health)
- **Structurally weak premises that die in the subjective lane**: bare WebView wrapper of a website (4.2 + Play minimum functionality), near-clone of an existing popular app (4.1/4.3), yet another entry in a saturated template category with no differentiator (4.3). These aren't instant bans — report them as HIGH PREMISE RISK with what differentiation would change the outcome
- **Betas**: anything the user describes as beta/early access belongs in TestFlight/testing tracks, not a store submission (2.2)

Output for a failed gate: verdict **NOT VIABLE (or HIGH PREMISE RISK)**, the specific blocking citations, and 1-3 concrete pivots that keep the user's intent but survive review (e.g., "sensor-only BP measurement → BP logging with a validated cuff via HealthKit").

### Phase 0 — Context intake

Determine: platform(s), app category (triggers regulated-category checks: health, finance, crypto, gambling, kids, dating, UGC, AI), monetization model, login model, SDK list (read Package.swift/Podfile/gradle), target audience, storefronts/territories. Each answer activates specific checklist sections in the references.

### Phase 1 — Static code + config audit

Grep/inspect the project. iOS: Info.plist (every NS*UsageDescription specific and truthful, ITSAppUsesNonExemptEncryption set, background modes justified), entitlements, PrivacyInfo.xcprivacy (required-reason API codes match actual usage — grep for stat/systemUptime/statfs/UserDefaults symbols), hardcoded IPv4s, http:// URLs, private API patterns, placeholder strings (lorem, TODO, "coming soon"), platform mentions ("Android", "Google Play") in user-facing strings, debug artifacts, tracking SDKs vs ATT implementation, social logins vs Sign in with Apple, IAP code vs restore-purchases code, account creation vs account deletion code, OTA update SDKs (CodePush/Expo Updates — must be disclosed in review notes). Android: merged manifest permissions each mapped to a visible feature, sensitive permissions vs declaration forms, target SDK vs current deadline, Play Billing vs external checkout paths.

### Phase 2 — Store metadata + console audit

Name/subtitle/keyword lengths, prohibited words ("beta", "free", "#1", competitor names, prices), screenshots depict real app on correct device classes, description promises vs shipped features (every claim must be reachable in-app), age-rating questionnaire honesty, privacy nutrition labels / Data safety form vs ACTUAL SDK traffic (this diff is automated on Google's side — capture network traffic on fresh install if possible), privacy policy + support URLs fetch with 2xx from a clean session, demo credentials present/working/full-access, review notes specific (never "bug fixes" alone; disclose OTA mechanisms, document hardware features with demo video), IAPs attached and "Ready to Submit", EU trader status, export compliance answered.

### Phase 3 — Simulated reviewer run (the phase static tools can't do)

Run the app the way a reviewer does — minutes, on their path, on their devices. Use the iOS Simulator tools (or emulator) to actually walk it:

1. Fresh install, cold launch — no crash, no debug banners, loads without cached state
2. The reviewer walk: onboarding → login with the demo account exactly as typed in review notes → main feature advertised in screenshot #1 → paywall (check price/term prominence, trial disclosure, restore button works) → settings → **tap Delete Account and verify it actually deletes** → each permission prompt (purpose string wording, app still usable on Deny)
3. Device matrix: smallest supported iPhone, and ALWAYS an iPad in compatibility mode for iPhone-only apps (classic blindside crash)
4. Adversarial pokes: deny every permission, kill network mid-flow, empty states (no lorem/broken-looking screens), every tappable in main nav does something
5. Push/ATT flows: app fully usable without granting; ATT prompt appears when expected and tracking respects denial
6. If login uses SMS/OTP: confirm a reviewer in California with no access to your phone can get in (static test code or bypass) — else CRITICAL

Log every screen visited; anything reachable that looks broken, placeholder, or undisclosed is a finding.

### Phase 4 — Report + fix loop

Output: verdict banner, findings grouped by severity with guideline citations and fixes, subjective-risk section (spam-similarity, paywall judgment, minimum functionality) with mitigation notes for reviewer notes, and a "submission package" checklist (demo creds, review notes text drafted for the user, attachments needed). Then fix CRITICAL → HIGH → WARN, re-run affected phases, repeat until GREENLIT. Offer the drafted Notes for Review text — specific notes prevent more rejections than code fixes.

## Non-negotiables (auto-CRITICAL, no judgment needed)

- Crash on launch anywhere in the review device matrix
- Demo account absent/broken for gated apps; backend not publicly reachable
- External payment path for digital goods (outside US-storefront 3.1.1(a) carve-out / enrolled Play programs)
- Tracking SDK without ATT (iOS) / Data safety mismatch (Play)
- Account creation without working deletion
- Placeholder content or dead privacy/support URLs
- Review-environment detection or remotely-toggled hidden features (termination risk, not just rejection)
- Third-party login without Sign in with Apple equivalent (iOS)
- AI features using third-party providers without disclosure/consent naming the provider

## Common mistakes running this skill

- Auditing only code: ~half of rejections are metadata, review-notes, and account-access failures — Phase 2 and the review-notes draft matter as much as Phase 1
- Trusting that a flow exists instead of tapping it (a Delete Account button wired to nothing passes static analysis)
- Skipping the iPad compatibility launch for iPhone-only apps
- Treating the references as complete forever: both stores change policies monthly. Before a real submission, fetch the "Recent changes" pages (Apple guidelines page, play.google/developer-content-policy) and reconcile
- Declaring GREENLIT with WARNs unexamined: subjective risks need explicit mitigation, usually via review notes, not silence
