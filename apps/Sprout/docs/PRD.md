# Sprout — PRD v1

## Context

We're building **Sprout**, an iOS focus / screen-time-reduction app. A SwiftUI scaffold (Swift Package + app target with Hatch / Focus / Garden / Stats / Settings tabs and an abandon-on-background detector) is already committed on `claude/screen-time-reduction-app-3Adty`.

Competitive research (full notes at the bottom of this file) showed a clear empty quadrant: **nobody combines Finch's emotional warmth with Forest's focus mechanic, and nobody owns the "non-punishing failure arc" or the "we don't pretend to block, we make focus rewarding" positioning.** That's the slot Sprout takes.

User decisions locked for v1: **broad audience first; one-time $4–6 price (Forest model); soft enforcement only (FamilyControls in v1.1); all four differentiators baked in.**

---

## 1. Vision

> Sprout is the friendly focus app that grows with you. Endearing creatures you actually want to spend time with — not punish yourself for. Honest about what it does, gentle when you slip, rewarding when you show up.

**Strapline (v1)**: *Focus, gently.*

---

## 2. Audience & jobs-to-be-done

**Primary (v1)**: broad — anyone trying to reclaim attention. Skews adult (25–45) because that's where the paying market lives, but tone & onboarding don't gate Gen Z out.

**Three core JTBDs**:

1. *"Help me start a focus session without it feeling like a chore."* — sub-3-tap start, no setup wall.
2. *"Make me want to come back tomorrow."* — emotional attachment to a creature, visible growth, gentle streaks.
3. *"Don't shame me when I slip."* — abandonment droops, doesn't kill. Streak forgiveness once a week.

Niche audiences we explicitly *don't alienate* but won't pander to in v1:
- ADHD users → ship sensory-friendly defaults (no shaming notifs, optional haptics) so we're well-positioned to lean in for v1.2.
- Students / Gen Z → keep nicknames + species variety so social sharing works organically.

---

## 3. Differentiators (all four, woven in)

| Pillar | How it shows up in v1 |
|---|---|
| **Creature warmth** (Finch-for-focus) | Named, nicknamed Sprouts; species personalities in micro-copy; idle breathing animation; mood reacts to recent activity |
| **Failure-forgiveness** (droop & recover) | Abandoned session → 1-hour droop, half-credit XP. Cancelled session → no XP, no droop. Streak survives one missed day per 7. |
| **Honest non-blocker framing** | Settings copy explicitly says: "Sprout doesn't pretend to block your apps — it makes focus feel worth doing. Hard blocking is coming in a future update." |
| **ADHD-aware micro-mechanics** | No shaming notifications. Optional haptic at session start/finish. Plain-language UI. 5-min minimum session length (not the typical 25). |

**Marketing pillar hierarchy** (use in this order in copy, screenshots, ads):

1. **Warmth** — lead with the creature. *"Meet a Sprout you'll actually want to come back to."*
2. **Forgiveness** — second beat, defuses the punishment objection. *"Slipped up? Your Sprout droops, doesn't die."*
3. **Honest framing** — third beat, builds trust with skeptics. *"We don't pretend to block your apps — we make focus feel worth doing."*
4. **ADHD-aware** — supporting evidence in detail pages and reviews, not headlines. *"Quiet by default. No shaming. 5-minute sessions are valid."*

### Notification policy (strict)

Sprout sends only three kinds of notifications, all opt-in:

| Trigger | Tone | Example |
|---|---|---|
| Session completed | Warm | "Mossie did it. 25 min." |
| Sprout recovered from droop | Reassuring | "Mossie's looking up again." |
| Weekly summary (Sundays) | Neutral | "3 sessions, 75 min focused this week." |

**Forbidden**: streak-loss warnings, "you haven't focused in X days", FOMO copy, badge counts > 1, push at user-chosen quiet hours.

---

## 4. v1 feature scope (locked)

Everything below is required for App Store submission. Anything not listed is v1.1+.

### 4.1 Hatch flow (first-run)
- Single screen: wobbling egg, nickname field, Hatch button.
- First Sprout's species randomized; reveal animation (~2s).
- No account, no permissions request, no email — straight to focus.

### 4.2 Focus tab (primary surface)
- Active Sprout sprite (200pt), nickname, species, growth stage.
- Circular timer ring with countdown (mm:ss) and progress arc.
- Stepper: 5 / 10 / 15 / 20 / 25 / 30 / 45 / 60 / 90 / 120 min (defaults to 25).
- Start / Give-up buttons (give-up requires confirmation; messaging: "no XP, but no droop").
- On completion: confetti + haptic + Sprout celebrates (~2s) before returning to ready state.
- On backgrounded mid-session: Sprout droops, half-credit awarded for elapsed minutes.

### 4.3 Garden tab
- Adaptive grid of all hatched Sprouts (96pt cards).
- Tap to set active. Long-press for detail sheet (species blurb, hatched-on date, total focus minutes, growth stage).
- "+" button → Hatch sheet (random species, excluding ones already owned until all 5 collected, then re-rolls).

### 4.4 Stats tab
- Today: streak, total focus minutes, sessions count.
- Last 7 days: bar list of focused minutes per day.
- That's it for v1. No charts, no comparisons, no exports.

### 4.5 Settings tab
- Default session length stepper.
- Soft mode explainer (always on).
- Hard mode card with "Coming in a future update" — no toggle yet.
- Notifications toggle (only for session-complete + droop-recovered, never streak-shame).
- Haptics toggle.
- About / version / privacy.

### 4.6 Persistence
- All data local in `Application Support/Sprout/garden.json`.
- No iCloud sync in v1 (defer to avoid CloudKit setup time).
- No account, no analytics, no third-party SDKs (privacy-positive, faster App Store review).

---

## 5. Out of scope for v1 (explicit cuts)

| Feature | Why deferred |
|---|---|
| FamilyControls / hard blocking | v1.1; entitlement approval is 2–3 weeks |
| iCloud sync between devices | v1.2; CloudKit adds complexity, low % multi-device users |
| Apple Watch app | v1.2; needs separate target + design pass |
| Live Activity for running timer | v1.1; nice-to-have, not blocking ship |
| Notifications scheduling / reminders | v1.2 |
| Cosmetics / unlockable themes | v1.3; not needed at one-time price |
| Calendar auto-focus | v2.0 |
| Family / squads | v2.0 |
| Achievements / badges | maybe never; reinforces gamification trap |
| Real-tree partnership | v2.0 if traction warrants |

---

## 6. Mechanics spec

### 6.1 Growth stages

| Stage | Cumulative minutes | Sprite scale |
|---|---|---|
| Seed | 0 | 0.6x |
| Sprout | 25 | 0.8x |
| Bloom | 120 | 1.0x |
| Elder | 600 | 1.15x |

(Same as scaffolded code; tuneable via `GrowthStage` enum.)

### 6.2 Session outcomes

| Outcome | XP | Droop | Streak |
|---|---|---|---|
| Completed | full planned minutes | clears any existing droop | counts toward day |
| Backgrounded mid-session | half elapsed minutes | 1 hour | doesn't count |
| Backgrounded within last 5s | full | clears droop | counts |
| Cancelled (Give-up button) | 0 | none | doesn't count |

### 6.3 Streaks
- Counts a day if ≥ 1 completed session that day.
- Continues if next completed session is the next calendar day.
- **Forgiveness rule (v1.1)**: one missed day per rolling 7 days doesn't break streak. *v1 ships strict; we add forgiveness based on early user feedback.*

### 6.4 Species roster (v1)
Five species, all unlocked from start, random hatch order:

| ID | Name | Emoji | Personality micro-copy |
|---|---|---|---|
| mossie | Mossie | 🌱 | Shy moss-pup. Loves quiet mornings. |
| pip | Pip | 🍄 | Wobbly mushroom. Believes in you. |
| fern | Fern | 🌿 | Stretches a little taller each day. |
| lumen | Lumen | ✨ | A spark that hums when you focus. |
| bramble | Bramble | 🌾 | Scruffy. Loyal. A little stubborn. |

Already in `Sources/SproutKit/Models/Species.swift`. v1.2 expands to ~12 species with custom illustrations.

### 6.5 Mood model
- Happy: focusMinutes ≥ 120 AND no active droop.
- Content: default state.
- Droopy: `droopyUntil` timestamp in the future (1 hour after abandonment).

Visual cues: tilt, droplet overlay (droopy), sparkle (happy). Already implemented in `App/Views/SproutSpriteView.swift`.

---

## 7. Monetization

**Model**: one-time **$4.99 USD** purchase (matches Forest's anchor; in app: product ID `com.sprout.unlock`).

**Free tier (always available, never gated)**:
- One named Sprout
- Focus sessions of any length
- Stats tab
- Settings

**Trial layer (auto-granted on install, expires day 8)**:
- Up to 3 hatched Sprouts (instead of 1)
- All 5 species discoverable

**Paid unlock ($4.99 one-time)**:
- Unlimited Sprouts
- Future species packs included free (within v1 series)
- One-time, no auto-renew, no subscription

**Paywall trigger logic**: paywall sheet appears *only* when the user actively tries to do something gated — tapping "+" in Garden when they're at the cap, or attempting to hatch on day 8+. Never on launch. Never on session completion. Never with a timer. The friction is real but earned.

**Why this works**:
- Matches user-stated direction.
- Sidesteps the trust-erosion that cost Finch its Trustpilot score.
- Higher App Store rating ceiling than subs (no "subscription fatigue" complaints).
- Lower LTV than $7/mo subs, but easier to launch and well-fitted to a creature/cosmetic-light v1.

**Future revenue (post-v1)**: optional one-time IAPs for cosmetic species packs ($1.99 per pack of 3) at v1.3, and a separate **Sprout Plus** annual sub ($14.99/yr) at v1.1 that unlocks hard-blocking + iCloud sync. Plus is *additive* — never gates the creature.

---

## 8. UX flow

```
First launch
  └─ HatchView (wobbling egg + name field)
       └─ Sprout reveal (~2s)
            └─ FocusView (default 25-min session pre-loaded)

Returning user
  └─ FocusView (active Sprout, last-used duration)
       ├─ Start → countdown ring → completion celebration → idle
       └─ Background → droop → half-credit, return to garden on relaunch

Tab bar (after first hatch): Focus · Garden · Stats · Settings
```

Already wired in `App/Views/RootView.swift`.

---

## 9. Tech architecture (status)

Already scaffolded on the branch:

| Layer | Path | Status |
|---|---|---|
| Core models | `apps/Sprout/Sources/SproutKit/Models/` | ✅ Sprout, Species, FocusSession, GrowthStage, Mood |
| Focus engine | `apps/Sprout/Sources/SproutKit/Engine/FocusEngine.swift` | ✅ State machine; tested |
| Garden rules | `apps/Sprout/Sources/SproutKit/Engine/Garden.swift` | ✅ Pure functions; tested |
| Test clock | `apps/Sprout/Sources/SproutKit/Engine/Clock.swift` | ✅ Deterministic time for tests |
| Persistence | `apps/Sprout/Sources/SproutKit/Persistence/GardenStore.swift` | ✅ JSON file store + in-memory store |
| Blocker stub | `apps/Sprout/Sources/SproutKit/Blocker/ScreenTimeBlocker.swift` | ✅ Protocol + Noop impl, ready for FamilyControls in v1.1 |
| App model | `apps/Sprout/App/AppModel.swift` | ✅ `@Observable` MainActor; mirrors engine state for SwiftUI |
| Views | `apps/Sprout/App/Views/` | ✅ All five views |
| Tests | `apps/Sprout/Tests/SproutKitTests/` | ✅ Engine, Garden, Persistence |

**v1 work status:**

| # | Item | Path | Status |
|---|---|---|---|
| 1 | `EntitlementStore` + `TrialPolicy` | `Sources/SproutKit/Entitlements/EntitlementStore.swift` | ✅ done |
| 2 | Free-trial gate (`Garden.canHatchMore`) | `Sources/SproutKit/Engine/Garden.swift` | ✅ done |
| 3 | Entitlement tests | `Tests/SproutKitTests/EntitlementGateTests.swift` | ✅ done |
| 4 | StoreKit 2 manager | `App/Purchases/PurchaseManager.swift` | ✅ scaffolded (needs real product `com.sprout.unlock` in App Store Connect) |
| 5 | Completion celebration view | `App/Views/CompletionCelebration.swift` | ✅ done |
| 6 | AppModel wired to entitlement | `App/AppModel.swift` | ✅ done |
| 7 | Privacy manifest | `App/PrivacyInfo.xcprivacy` | ✅ done |
| 8 | Marketing copy | `marketing/app-store-listing.md` | ✅ done |
| 9 | Wire `CompletionCelebration` into FocusView completion state | `App/Views/FocusView.swift` | ⏳ todo |
| 10 | Wire paywall sheet into Hatch + Settings when `canHatchMore == false` | `App/Views/HatchView.swift`, `App/Views/SettingsView.swift` | ⏳ todo |
| 11 | Real `.xcodeproj` checked in | `apps/Sprout/Sprout.xcodeproj/` | ⏳ Mac-only task |
| 12 | Asset catalog + App Icon | `apps/Sprout/App/Assets.xcassets/` | ⏳ needs design |

**v1.1 work** (Screen Time):
1. Implement `FamilyControlsBlocker: ScreenTimeBlocker` in `apps/Sprout/App/Blocker/FamilyControlsBlocker.swift`.
2. Add FamilyControls + ManagedSettings + DeviceActivity entitlements (Apple approval required).
3. Build app picker UI using `FamilyActivityPicker`.
4. Inject `FamilyControlsBlocker` at `SproutApp` composition root in place of `NoopScreenTimeBlocker`.

---

## 10. Success metrics

Target by 30 days post-launch:

| Metric | Target | Why |
|---|---|---|
| App Store rating | ≥ 4.7 | Category benchmark (Forest 4.9, one sec 4.8) |
| Day-1 retention | ≥ 50% | Hatch flow has to land |
| Day-7 retention | ≥ 25% | Tests novelty resilience |
| Day-30 retention | ≥ 12% | Real habit formation; Forest churn proves this is hard |
| % sessions completed | ≥ 60% | Validates timer-length defaults |
| Avg sessions per active day | ≥ 2 | Engagement depth |
| Free → paid conversion | ≥ 8% | Forest-style anchor; one-time $4.99 |
| 1-star rate | < 5% | Especially watch for "doesn't really block" complaints — our honest framing should defuse this |

---

## 11. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Users expect hard blocking and 1-star us when they realize it's soft only | Settings copy + App Store description lead with "motivation app, not blocker"; reinforces in onboarding |
| Novelty fade after 2–4 weeks (Forest's curse) | Five species + growth stages give 600+ minutes of progression; v1.2 species packs extend it |
| App Store review rejection (focus apps get scrutinized for Screen Time misuse claims) | We don't claim Screen Time integration in v1; clean review path |
| `FocusEngine` background timer drift | Already use wall-clock deltas (not setInterval); scenePhase handler catches background |
| Single dev / no design partner means weak art | Use SF Symbols + emoji + shape-driven sprites in v1; commission illustration for v1.2 species pack |
| Sub-creep (we promised one-time, then add Plus) | Plus must add genuine new value (hard blocking) — never gates v1 functionality |

---

## 12. Verification plan

### Pre-ship checklist (v1)

**Logic (runs on macOS via SwiftPM)**:
1. `cd apps/Sprout && swift test` — all SproutKit tests pass (engine, garden, persistence, entitlement gate).

**Behavior (runs in Xcode + iOS 17 simulator)**:
2. First-time hatch flow end to end → Sprout in Garden, default Focus screen ready.
3. Run a 5-min session, let it complete → `CompletionCelebration` shows, +5 min XP.
4. Run a 5-min session, background the app at 30s → return to find Sprout droopy + half-credit.
5. Run a 5-min session, hit Give-up → no XP, no droop.
6. Hatch 3 Sprouts → check Garden grid + tap-to-activate.
7. Attempt 4th hatch as free user → paywall sheet appears.
8. Run a `PurchaseManager` purchase flow in StoreKit sandbox → entitlement flips to `.paid`, 4th hatch succeeds.
9. Run 7 sessions across 2 days → verify streak counter.
10. Check Stats shows correct totals.
11. Force-quit + reopen → garden state persisted to disk.
12. Settings flips for haptics + notifications behave correctly.
13. App Store Connect: configure non-consumable product `com.sprout.unlock` at $4.99, link `PrivacyInfo.xcprivacy`.

### Beta (TestFlight, 2 weeks pre-launch)
- 50 users, mix of focus-app veterans + novices.
- Track: time to first completed session, D7 retention, 1-star themes.
- Watch for: "thought it would block apps" complaints (signals onboarding copy weak).

### Post-launch
- Weekly App Store review scrape; categorize 1-star themes.
- Track free → paid conversion daily for first 30 days.
- If D7 < 20%, revisit completion celebration / streak forgiveness.

---

## 13. Phased roadmap

| Version | Scope | Timeline |
|---|---|---|
| **v1.0** | Soft enforcement, 5 species, $4.99 unlock, this PRD | 4–6 weeks from PRD lock |
| **v1.1** | FamilyControls hard blocking + Sprout Plus sub + Live Activity | +6 weeks (after entitlement) |
| **v1.2** | iCloud sync, Apple Watch app, scheduled reminders | +8 weeks |
| **v1.3** | Cosmetic species packs (paid IAPs), 12-species roster, themes | +6 weeks |
| **v2.0** | Calendar auto-focus, family/squads, optional real-tree partner | TBD |

---

## Appendix: Phase 1 research summary

(Detailed competitive landscape moved here for reference; informed every section above.)

### Direct & adjacent competitors

| App | Mechanic | Price | Rating / volume | Standout |
|---|---|---|---|---|
| Forest (Seekrtech) | Plant tree, dies if you leave | $3.99 one-time | 4.9★ / 23.7K | Real reforestation; multi-platform |
| Flora | Free trees, real-tree subs | $2-10/yr | 4.8★ / ~82K | Uncapped real-tree planting |
| Focus Plant | Raindrop currency, 200+ plants | Freemium | sparse | More forgiving than Forest |
| Finch | Self-care pet (NOT focus) | $9.99/mo | 4.5★, 2.5★ Trustpilot (billing) | Emotional pet bond |
| Bloom (Shark Tank) | NFC keycard + hard block | One-time hardware | 4.8★ (new) | Hardware kill-switch |
| Opal | Analytics + coworking | $100/yr or $400 lifetime | 4.8★ / ~60K | Premium analytics leader |
| Jomo | Blocking + journaling + squads | ~€7/mo | 4.7★ / 100K+ DL | Mood journaling |
| Brick | Physical NFC tag | $59-99 one-time | viral 2024-25 | Hardware kill-switch |
| one sec | Pause-before-open | $4/mo or $50 lifetime | 4.8★ / 22K+ | Peer-reviewed: -57% opens |
| ScreenZen | Soft block, free | Free | 4.2★ / 9.3K | Honest, open ethos |
| Roots | Digital-Dopamine + Monk Mode | $10/mo or $60/yr | newer, TC-covered | "Quality not minutes" |
| AppBlock | Strict Mode app+web | $5/mo | 4.6★ / 5.5K | Website blocking |
| Freedom | Cross-device blocking | $40/yr | 4.7★ | Multi-platform |
| Apple Screen Time | Native, soft | Free | n/a | Easily bypassed |
| Habitica | RPG-habits | Free + cosmetic sub | 3.9★ recent | Cosmetic-only monetization model |

### Cross-cutting "what users hate"
1. Novelty fade on gamification (Forest)
2. Punishment mechanics (Forest, Habitica)
3. Paywalls on emotional core (Finch)
4. Bypassable "hard blocks" → trust loss
5. App-management fatigue
6. Mandatory daily check-ins
7. Billing-trust failures (Finch Trustpilot 2.5★)

### Apple Screen Time API reality
50-app token cap, 15-min minimum, 20 concurrent activities, crashes on iOS 17.4+. Brick exists *because* the OS API is unreliable. Sprout's "honest non-blocker" framing is a feature, not an excuse.

### Sources
- Forest: https://apps.apple.com/us/app/forest-focus-for-productivity/id866450515
- Flora: https://apps.apple.com/us/app/flora-green-focus/id1225155794
- Finch: https://apps.apple.com/us/app/finch-self-care-pet/id1528595748
- Opal: https://www.opal.so/
- Jomo: https://jomo.so/
- Brick: https://apps.apple.com/us/app/brick-ditch-distractions/id6448794069
- one sec: https://one-sec.app/
- Roots: https://www.getroots.app/
- ScreenZen: https://screenzen.co/
- Bloom: https://bloom.inc/
- Apple Screen Time API state-of-2024: https://riedel.wtf/state-of-the-screen-time-api-2024/
- Roots TechCrunch: https://techcrunch.com/2024/06/20/roots-introduces-a-screen-time-app-for-tracking-digital-dopamine/
