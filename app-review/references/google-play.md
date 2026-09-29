# Google Play — Auditor Reference

Concrete checks per policy family. Cite the policy name in findings. Policy center: https://play.google/developer-content-policy/ (check "Recent changes" before every submission — Google gives ~30-day compliance windows).

## Console declarations (all mandatory before review)

- [ ] Privacy policy URL: live, named developer entity, on store listing AND in-app; required for sensitive permissions or child-targeting
- [ ] Ads declaration (any ad SDK counts; misdeclaring risks suspension)
- [ ] App access: working sign-in instructions, up to 5 credential sets; disclose OTP/MFA quirks. Reviewers who can't log in reject silently — top cause
- [ ] Target audience + content declaration (children in audience → Families policy applies)
- [ ] Content rating questionnaire (unrated apps get removed)
- [ ] Permissions Declaration Form for sensitive permissions
- [ ] Health apps declaration (any health feature, even secondary); financial features declaration for finance apps
- [ ] News/COVID/government declarations if applicable

## Data safety form (top rejection source)

- [ ] Every collected/shared data type declared across the 23 categories. "Collected" = transmitted off device, INCLUDING all SDK traffic (Firebase, analytics, ads) even if it never reaches your servers
- [ ] Audit method: capture app network traffic on a fresh install, diff observed endpoints/payloads against the form
- [ ] Exemptions applied correctly: on-device only, E2EE, ephemeral, service provider, anonymized
- [ ] Security section: encryption in transit, deletion mechanism
- [ ] Form updated whenever data practices change

## Prominent disclosure + consent (User Data policy)

- [ ] In-app disclosure (not just privacy policy), in normal usage flow, BEFORE the runtime permission request
- [ ] Names the data type explicitly ("location") and how it's used/shared
- [ ] Consent = affirmative action; back/home/tap-away doesn't count; no auto-dismissing dialogs

## Sensitive permissions

- [ ] **Background location**: core-feature only, one-feature declaration form, ≤30s demo video, disclosure includes "background/when app is closed", compliant on ALL tracks including internal
- [ ] **SMS/Call Log**: only default-handler or narrow exceptions; SMS OTP verification is an INVALID use (use SMS Retriever API)
- [ ] **MANAGE_EXTERNAL_STORAGE**: file managers/backup/antivirus only; prefer MediaStore/SAF
- [ ] **AccessibilityService**: accessibility tools set `isAccessibilityTool=true`; other uses need declaration + separate disclosure; no autonomous actions
- [ ] **READ_MEDIA_IMAGES/VIDEO**: only if broad media access is core (gallery apps); otherwise Android Photo Picker or READ_MEDIA_VISUAL_USER_SELECTED; a custom picker UI alone doesn't qualify
- [ ] Every permission maps to a visible user-facing feature
- [ ] Loan apps: banned from contacts, external storage, fine location, phone numbers

## Monetization

- [ ] All digital goods/services through Play Billing (currency, unlocks, subscriptions, ad-removal, cloud features)
- [ ] Exemptions: physical goods, bill pay, consumption-only, 1:1 live services, P2P tips (100% pass-through)
- [ ] No steering to external payment outside enrolled programs (EEA/DMA, Korea, India, US user-choice)
- [ ] Subscriptions: pre-purchase display of price, frequency, auto-renewal, trial auto-conversion, cancellation method; easy online cancel; no misleading price framing (monthly price shown big for an annual charge); localized terms

## Store listing (Metadata policy)

- [ ] Title ≤30 chars, no emojis/ALL CAPS/special-char runs/notification-dot icons
- [ ] No performance claims ("#1", "Best"), price text ("free", "10% off"), or Play program references in metadata
- [ ] No keyword stuffing, unattributed testimonials, unauthorized celebrity/brand use
- [ ] Screenshots/video depict the real app experience

## Spam, minimum functionality, deception

- [ ] Not a bare WebView wrapper; native features must beat the website (quality bar strengthened Aug 2024)
- [ ] No crashes/ANRs; real utility; no template clones or made-for-ads apps
- [ ] Functionality matches claims; no hidden/dormant features; no fake system UI
- [ ] NO review-environment detection altering behavior (account-termination trigger)
- [ ] UGC apps: moderation + reporting + blocking. AI content apps: in-app offensive-content reporting

## Families (if children in target audience)

- [ ] No AAID/IMEI/MAC/persistent-ID transmission; no location collection in child-only apps
- [ ] Only Families Self-Certified Ads SDKs, no personalized ads
- [ ] Mixed audience: neutral age screen gating data/ads behavior
- [ ] COPPA/GDPR-K; no violence/gambling/dating/sexual content or links to non-compliant destinations
- [ ] Social/dating apps: child safety standards self-certification (since Jan 2025)

## Health and financial

- [ ] Health: declaration form; medical-device apps hold regulatory clearance; others carry "not a medical device" disclaimer; no anti-consensus claims; Health Connect data is sensitive
- [ ] Financial: Finance category; personal loans show min/max repayment period, max APR, representative example in metadata; US APR <36%; no ≤60-day loans; country license docs where required; binary options prohibited

## Technical gates

- [ ] Target API level: new apps/updates must target API 36 by Aug 31, 2026 (Wear/Automotive 35; TV/XR 34); older targets become invisible to new users
- [ ] AAB format (Play App Signing); 150MB base limit → Play Asset/Feature Delivery
- [ ] Account deletion (if accounts exist): prominent in-app path AND a web link usable without reinstalling, declared in Data safety form; must actually delete, not freeze
- [ ] New personal accounts (post Nov 2023): closed test with 12 opted-in testers for 14 continuous days before production access

## Pre-launch report (run it, read it)

Auto-runs on bundle upload: device-matrix install + auto-crawl.
- Stability: crashes, ANRs, restricted non-SDK API usage
- Performance: FPS/CPU/memory/network per device
- Accessibility: content labels, touch targets, contrast
- Provide test credentials in console (auto-fill only works with standard Android widgets — custom login UIs need Robo scripts)
- Security notices flag vulnerable libraries (unsafe TrustManager, old OpenSSL)

## Enforcement model

Policy Status page shows enforcements: rejected (old version stays live) → removed (gone until fixed) → suspended (strike). One appeal per enforcement. Google blocked 2.28M violating submissions in 2023 — assume automated + human review of everything declared and observed.
