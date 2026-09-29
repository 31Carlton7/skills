# Apple App Store — Auditor Reference

Cite guideline numbers in findings. Source: developer.apple.com/app-store/review/guidelines (verify "Recent changes" before each submission; rules below current as of Aug 2026).

## Apple's own pre-submission bar

- [ ] Tested for crashes on a physical device, not just simulator
- [ ] Demo account credentials in App Review Information, unlocking ALL features including paid tiers (or approved demo mode)
- [ ] Backend LIVE and reachable during the review window
- [ ] Notes for Review explain every non-obvious feature and IAP, with supporting docs (licenses, clearances)
- [ ] You own every third-party SDK's behavior in the binary — Apple holds you responsible

## 1.x Safety

- [ ] 1.1.6: no fake device data, prank call/SMS, fake trackers (rejected even "for entertainment")
- [ ] 1.2 UGC/social features require ALL FOUR: content filtering, report mechanism, user blocking, published contact info. NSFW hidden by default. Creator platforms: age-identification (1.2.1(a))
- [ ] 1.3 Kids Category: no out-links/purchases outside parental gate, no third-party analytics/ads (narrow exceptions); obligations persist across updates
- [ ] 1.4: sensor-only blood pressure/glucose/temperature claims = auto-reject (1.4.1); dosage calculators only from manufacturers/hospitals/FDA-cleared (1.4.2); DUI checkpoints only from law enforcement
- [ ] 1.5: support URL must contain a working contact method — reviewers click it

## 2.x Performance (the #1 and #2 rejection families)

- [ ] 2.1: no placeholder text, broken links, "coming soon"; IAPs visible/complete/functional for the reviewer; no crashes; >40% of unresolved rejections live here
- [ ] 2.2: "beta"/"demo"/"trial" builds and wording belong in TestFlight, not the store
- [ ] 2.3.1(a): no hidden/dormant features; specific (not generic) review notes for new features; disclose OTA-update mechanisms (CodePush/Expo Updates) by name
- [ ] 2.3.3: screenshots show the app IN USE (not splash/login art); 2.3.7: name ≤30 chars, no keyword stuffing/competitor names/prices; 2.3.8: icons+screenshots suitable for 4+; 2.3.10: no Android/other-platform mentions anywhere; 2.3.12: real "What's New"
- [ ] 2.4.1: iPhone apps run on iPad in compatibility mode — launch it in an iPad simulator before submitting
- [ ] 2.5.1: public APIs only (automated binary scan); frameworks for intended purpose
- [ ] 2.5.2: no downloading/executing functionality-changing code
- [ ] 2.5.4: background modes actually used for their purpose
- [ ] 2.5.5: must work on IPv6-only NAT64 (review lab network); hardcoded IPv4 is the classic failure
- [ ] 2.5.14: explicit consent + indicator for any camera/mic/screen recording
- [ ] 2.5.18: ads only in main binary, close buttons on interstitials, in-app ad-report mechanism

## 3.x Business

- [ ] 3.1.1: ALL digital unlocks via IAP (no license keys, external checkout, crypto unlocks); credits can't expire; Restore Purchases required; loot-box odds disclosed
- [ ] 3.1.1(a): external purchase links allowed WITHOUT entitlement on the **US storefront only** (post-Epic, May 2025). Shipping external-link UI globally is still a violation elsewhere — gate by storefront
- [ ] 3.1.2(c): paywall states what/price/duration BEFORE purchase; price and renewal terms must be prominent (low-contrast/tiny/below-fold = rejection); trial auto-conversion terms shown
- [ ] 3.1.3: person-to-person real-time services (1:1 tutoring/telemedicine) may use external payment; one-to-many must use IAP; physical goods MUST use non-IAP
- [ ] 3.1.5: crypto wallets need Organization account; no on-device mining; exchanges need per-jurisdiction licenses
- [ ] 3.2.2(ix): personal loans ≤36% APR, no ≤60-day full repayment; (x): can't force ratings/downloads to unlock features
- [ ] 3.2.1(viii): trading/investing apps submitted by the licensed institution's account

## 4.x Design

- [ ] 4.1/4.3: no clones/copycats; saturated categories need real differentiation; document differentiators in review notes for template-adjacent apps
- [ ] 4.2: more than a repackaged website; 4.2.6: white-label apps must ship from the client's own account
- [ ] 4.5.4: push permission NEVER required to use the app; marketing pushes need in-app opt-in + opt-out
- [ ] 4.7: mini-app/emulator/chatbot platforms need UGC-style moderation, software index, age restriction
- [ ] 4.8: ANY third-party login (Google/Facebook/X) requires an equivalent privacy-preserving option (Sign in with Apple). Exempt: own-account-only apps, institutional logins, single-service clients
- [ ] 4.10: can't charge for OS capabilities (push, camera, iCloud)

## 5.x Legal

- [ ] 5.1.1(i): privacy policy link in App Store Connect metadata AND in-app, both live
- [ ] 5.1.1(ii): purpose strings describe the actual, specific use; generic/empty = rejection
- [ ] 5.1.1(iv): app still works when permissions are denied; no irrelevant permission demands
- [ ] 5.1.1(v): account creation → in-app account deletion that actually deletes (not deactivates), findable in settings; SIWA apps must call the token-revocation endpoint; no phone/email-only deletion
- [ ] 5.1.1(ix): regulated fields (banking, healthcare, gambling, cannabis, crypto exchange) require the legal entity's Organization account
- [ ] 5.1.2: ATT before tracking; fingerprinting banned even with consent; no gating features on push/location/tracking permission; no mass-invite contact flows
- [ ] 5.1.3: never store health data in iCloud; no health data for ads
- [ ] 5.2.3: no downloading/converting media from YouTube/SoundCloud etc.
- [ ] 5.3: gambling licensed + geo-restricted + free on store; no IAP for real-money gaming credit
- [ ] 5.6.1: only SKStoreReviewController for review prompts; no custom prompts

## Beyond the guidelines (submission gates)

**Privacy manifest (PrivacyInfo.xcprivacy)** — since May 2024
- [ ] Declares NSPrivacyTracking (+ NSPrivacyTrackingDomains if true), NSPrivacyCollectedDataTypes, NSPrivacyAccessedAPITypes
- [ ] Required Reason APIs each have an approved reason code: FileTimestamp (DDA9.1/C617.1/3B52.1), SystemBootTime (35F9.1/8FFB.1), DiskSpace (85F4.1/E174.1), ActiveKeyboards (3EC4.1/54BD.1), UserDefaults (CA92.1/1C8F.1/C56D.1)
- [ ] Missing → ITMS-91053/91054/91055/91057 upload rejections; big SDKs must ship their own manifest + signature

**Privacy nutrition labels**
- [ ] Every data type the app OR its SDKs transmit off-device declared across the 14 categories, sorted into Tracking / Linked / Not Linked
- [ ] Inaccurate labels = 2.3.1 violation; diff labels against actual SDK traffic and the aggregated Xcode privacy report

**ATT specifics**
- [ ] NSUserTrackingUsageDescription present if tracking SDKs exist; tracking domains fail closed pre-consent; no tracking after "Ask App Not to Track"

**Export compliance**
- [ ] ITSAppUsesNonExemptEncryption set explicitly in Info.plist (false for HTTPS/Keychain/OS-crypto only); custom crypto → classification docs; annual BIS self-classification may apply

**Age rating (2025 overhaul)**
- [ ] New tiers 4+/9+/13+/16+/18+; updated questionnaire (chat, UGC, AI chatbots, medical topics) answered — required since Jan 2026 to submit updates; AI chat or unfiltered web ⇒ don't expect low ratings

**EU DSA trader status**
- [ ] Monetizing in the EU requires verified trader info in App Store Connect (public on EU pages) or the app is removed from EU storefronts

**Build/submission floor**
- [ ] Built with the current required SDK (Xcode 26 / iOS 26 SDK as of April 2026); screenshots per device class at correct dimensions; name ≤30, subtitle ≤30, promo ≤170, description ≤4000, keywords ≤100

## App Store Connect state (check via ASC before submitting)

- [ ] Build in VALID state; IAPs "Ready to Submit" and attached to the submission
- [ ] Support URL and marketing URL return 2xx (Apple fetches them)
- [ ] Age questionnaire done, territories + pricing configured, export compliance answered

## Process facts

- Rejection screenshots are in Resolution Center (they show the tested device)
- Metadata/notes/demo-video fixes don't need a new binary
- Repeated same-guideline rejections slow future reviews; appeals succeed ~20%
