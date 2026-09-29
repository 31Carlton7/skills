# Real-World Rejection Patterns — What Official Docs Undersell

Field-tested rejection causes with the guideline/policy each maps to. Check every one; these are where "compliant" apps still die.

## Review logistics (the #1 lore category)

- Demo account missing, expired, wrong password, or region-locked → 2.1. Fill "Sign-in required" fields; unlock ALL features including paid tiers; multi-role apps need creds per role
- SMS/OTP login the reviewer can't receive (they're in California; foreign-number OTP = instant fail) → 2.1/2.3.1. Fix: whitelisted test number with a static code, or demo bypass
- Backend/staging down during the review window → 2.1. Reviewers don't retry; keep prod up and warm
- Hardware-dependent features (BLE devices, external cameras) with no demo video attached → 2.1. Attach a demo video in the Attachment field
- "Bug fixes and improvements" as the only review notes when new features shipped → 2.3.1 (notes must describe new functionality with specificity)
- Feature flags off for the review account so advertised features are unreachable → 2.3.1

## Device-matrix surprises

- **iPad crash for iPhone-only apps**: reviewers run iPhone apps on iPad in compatibility mode → 2.4.1/2.1. Pre-submit: launch in an iPad simulator, or set device family/"Requires full screen" correctly
- Crash on oldest-supported OS or smallest screen (SE-class) → 2.1
- IPv6-only failures: Apple's review network is NAT64; hardcoded IPv4 addresses are the tell → 2.1/2.5

## Completeness and placeholders (2.1, ~40% of all rejections)

- Lorem ipsum, "coming soon", "under construction", TODO/TBD anywhere reachable
- Buttons that do nothing; broken in-app links; empty states that look broken (seed sample data)
- Debug artifacts in release builds: Flutter DEBUG banner, RN dev overlay → 2.3.1
- Support URL 404 (Apple actually fetches it; a private Notion page fails) → 1.5. Dead privacy-policy URL → 5.1.1(i). Test both in incognito

## Metadata

- Screenshots not matching the real app; marketing mockups only → 2.3.3
- Android UI visible in iOS screenshots → 2.3.10
- Mentioning other platforms in description or in-app strings → 2.3.10
- Price in name/icon/screenshots, or metadata price ≠ actual charge → 2.3.7/3.1.2
- "Beta"/"test"/"demo"/"trial" in name or metadata → 2.2 (betas go to TestFlight)
- Name >30 chars, keyword stuffing, competitor names, "best/#1" → 2.3.7 (Play adds: no testimonials, emoji, ALL CAPS)
- Home-screen display name ≠ App Store name → 2.3.7

## Hidden/dormant functionality (2.3.1, termination territory)

- Undisclosed OTA update mechanisms (CodePush, Expo Updates): disclose by name and scope in review notes
- Remotely toggled features; hidden gambling/streaming behind geo/date switches → egregious, can terminate the developer account
- Unlocking web-game/web-payment layers post-approval → ban pattern
- NEVER detect the review environment and alter behavior (both stores treat this as fraud)

## Minimum functionality

- WebView wrapper with no native capability → 4.2 (mitigate: offline behavior, native navigation, push, widgets)
- Template/white-label clone → 4.3 spam. Fix: spell out concrete differentiators in review notes
- Copycat name/UI of a popular app → 4.1

## Payments and subscriptions

- Stripe/PayPal/external checkout for digital goods → 3.1.1 CRITICAL (external OK only for physical goods/services and 3.1.3 categories)
- IAP present but no Restore Purchases → 3.1.1
- IAP products not attached to the submission / not "Ready to Submit" in ASC → "unable to complete purchase" rejection
- Paywall: price/duration must be the most prominent text; trial auto-renewal terms shown pre-confirmation → 3.1.2 (often fixable with font-size/contrast alone)
- Forcing rating/share/social-follow to unlock content → 3.1.2(a)

## Privacy and permissions

- Vague purpose strings ("we need camera access to work") → 5.1.1; empty strings auto-reject
- Tracking SDK present (Facebook, Adjust, AppsFlyer, Firebase Analytics) but no ATT prompt / NSUserTrackingUsageDescription → 5.1.2
- ATT gotchas: nudging primer screens, tracking after denial, gating functionality on tracking consent, prompt never appearing because another dialog was pending → 5.1.2
- Account creation without working in-app deletion (Apple taps the button and verifies the account is gone) → 5.1.1(v)
- Nutrition Label / Data safety form ≠ actual SDK network traffic (Google runs automated traffic analysis) → 5.1.1 / Play Data safety
- Third-party AI features without a disclosure/consent modal naming the provider and data shared → 5.1.2(i) (2025+ enforcement; real rejection for undisclosed Claude-powered editing)

## Push notifications and sign-in

- Notification permission hard-gating onboarding → 4.5.4
- Marketing pushes without in-app opt-in + opt-out → 4.5.4
- Google/Facebook login without Sign in with Apple offered equivalently → 4.8
- Forced login when the app has no account-based features → 5.1.1

## Regulated categories

- Crypto: wallets need an Organization developer account (re-enroll takes 2-4 weeks); exchanges need licensing + geo-restriction; mining on device banned → 3.1.5(b). Play requires government licenses for custodial wallets
- Gambling: licenses, geo-blocking, age gate, ASC territory limits → 5.3
- Health: no health data in iCloud, no false HealthKit writes, no health data for ads → 5.1.3; dosage/medical-advice apps may need institutional developers → 1.4
- Kids: no external links outside a parental gate, no behavioral ads, COPPA/GDPR-K → 1.3/5.1.4
- UGC without filter + report + block + contact info → 1.2 (expect a 17+ rating demand)

## Process meta-knowledge

- Reviewer screenshots live in Resolution Center, not the rejection email; they reveal the device/size used
- Many rejections are fixable WITHOUT a new binary: metadata, review notes, demo video, paywall tweaks
- Replying with questions restarts the clock; appeals succeed ~20% of the time
- Reviewers spend minutes: first-launch path → login → paywall → settings (delete account) → permission prompts. That exact walk is what the simulated review must exercise
