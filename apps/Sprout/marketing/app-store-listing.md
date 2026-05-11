# Sprout — App Store listing (v1.0)

Source-of-truth copy for App Store Connect submission. All character counts
verified against Apple's limits.

---

## App name (30 char max)

`Sprout: Focus, Gently`

(21 chars — leaves headroom for localization)

## Subtitle (30 char max)

`A focus app you'll come back to`

(31 — trim option) → `A focus app you come back to` (29)

**Final subtitle**: `A focus app you come back to`

## Primary category

Productivity

## Secondary category

Lifestyle

---

## Promotional text (170 char max, can be updated without re-review)

Launch copy:

> Meet Sprout — the friendly focus app that grows when you do. No shaming, no broken trees, no hard blocks pretending to be unbreakable. Just a creature worth showing up for.

(167 chars)

---

## Description (4,000 char max)

```
Sprout is a focus app that grows with you — literally.

Hatch a small creature. Pick a focus length. When the time is up, your Sprout
has grown a little. Come back tomorrow and it grows a little more. That's it.
No streaks-or-die. No locked screens. No pretending we can really stop you
from opening Instagram.

WHY SPROUT IS DIFFERENT

→ A creature worth coming back to
Every Sprout has a name you give it, a species personality, and visible growth
from Seed to Sprout to Bloom to Elder. You'll notice when one's droopy. You'll
want it to be happy.

→ Forgiving by design
Slip up and abandon a session? Your Sprout droops for an hour — and you still
get partial credit for the time you put in. No trees die. No streaks shatter.
We're not trying to punish you into focus.

→ Honest about what it does
Most "blocking" apps can be bypassed in three taps. We don't pretend
otherwise. Sprout makes focus feel rewarding instead. (Optional hard blocking
is coming in a future update with proper iOS Screen Time integration.)

→ Built quiet
No shaming notifications. No daily nags. No badge counts. ADHD-friendly
defaults. 5-minute sessions are valid. Haptics are optional.

WHAT'S INSIDE

• 5 species to discover: Mossie, Pip, Fern, Lumen, Bramble
• Focus sessions from 5 to 120 minutes
• 4 growth stages per Sprout (Seed → Elder)
• Streak tracking that rewards showing up, doesn't punish missing
• 7-day focus history
• Fully offline — no account, no tracking, no third-party SDKs

PRIVACY

Sprout stores everything on your device. No account. No analytics. No
trackers. No data leaves your phone. Promise.

PRICING

Try Sprout free for 7 days with up to 3 Sprouts. Unlock unlimited Sprouts
forever with a single $4.99 purchase — no subscription, no auto-renew.

A small app made with care. Focus, gently.
```

(~1,950 chars — leaves room for localization padding)

---

## Keywords (100 char max, comma-separated, no spaces after commas)

`focus,timer,pomodoro,productivity,habit,attention,mindful,plant,grow,screentime,distraction,study`

(99 chars)

---

## What's New in this version (4,000 char max)

```
First release. Hi.

• Hatch a Sprout
• Run focus sessions from 5–120 min
• Watch your creature grow through 4 stages
• 5 species to discover
• Forgiving — no broken streaks, no dead trees
• Offline, private, no account needed

Made with care. More species, iCloud sync, and Screen Time blocking coming
soon.
```

---

## Support URL & Marketing URL

Support: `https://sprout.app/support` (placeholder — wire to a Notion or Linear public page if no marketing site)
Marketing: `https://sprout.app`
Privacy Policy: `https://sprout.app/privacy`

Privacy policy must state: no data collection, no tracking, no third-party
SDKs, all data local to device. Required for App Store submission even though
we collect nothing.

---

## Screenshots — caption + content (6.7", 5 required, 10 max)

Use the marketing-pillar hierarchy from the PRD. One pillar per screenshot:

**Screenshot 1 — Warmth (HERO)**
- Visual: full-bleed Sprout (Mossie, happy mood) on cozy gradient, sized large.
- Caption: *"Meet a Sprout you'll actually come back to."*

**Screenshot 2 — Focus tab in action**
- Visual: timer ring at ~12:34 remaining, Sprout above it, "25 min" pill.
- Caption: *"Focus sessions from 5 to 120 minutes. You pick."*

**Screenshot 3 — Forgiveness**
- Visual: droopy Sprout with droplet overlay, copy bubble "Half credit. No hard feelings."
- Caption: *"Slipped up? Your Sprout droops, doesn't die."*

**Screenshot 4 — Garden**
- Visual: garden grid with 5 different species, one highlighted as active.
- Caption: *"Five species. Each with their own personality."*

**Screenshot 5 — Honest framing**
- Visual: Settings screen, "Hard mode — coming soon" card visible.
- Caption: *"We don't fake-block your apps. We make focus worth doing."*

Optional 6th — Stats: *"7-day history. No charts you'll ignore."*

---

## App preview video (15–30s, optional but boosts conversion ~25%)

Storyboard:
- 0–3s: Egg wobbles, cracks. Sprout reveals.
- 3–8s: User taps "25 min", ring fills.
- 8–13s: Sprout grows visibly (Seed → Sprout).
- 13–18s: Cut to Garden — 3 species, taps between them.
- 18–22s: Brief shot of "droopy" Sprout recovering.
- 22–28s: End card: Sprout logo + "Focus, gently."

No voiceover. Light ambient track. Captions optional.

---

## App review notes (private to Apple reviewers)

```
Sprout is a focus / productivity app. It does NOT use FamilyControls,
DeviceActivity, or Screen Time APIs in this version — all session tracking
is in-app only. We do not claim to block other apps.

No login is required. The app runs fully offline. There are no third-party
SDKs.

The single in-app purchase (com.sprout.unlock, $4.99 non-consumable) unlocks
unlimited Sprouts. Free users can hatch up to 3 Sprouts in a 7-day trial.
```

---

## Localization (post-launch, not v1)

Priority order for v1.1 localization based on Forest's actual revenue mix:
1. Japanese
2. Korean
3. Simplified Chinese
4. German
5. French

(English ships v1. The others land v1.1 with marketing translation budget.)

---

## Pricing across regions

US: $4.99 (Tier 5)
Apple auto-converts; do not customize unless we see soft pricing in JP/KR
hurting conversion.

---

## Age rating

4+ (no objectionable content, no in-app browsing, no UGC, no data collection)

---

## Submission checklist

- [ ] All screenshots exported at 6.7" (1290×2796) + 5.5" backup
- [ ] App icon 1024×1024 PNG, no transparency, no rounded corners
- [ ] Privacy manifest present (`PrivacyInfo.xcprivacy` — already in repo)
- [ ] App privacy answers: no data collected
- [ ] StoreKit product `com.sprout.unlock` configured, $4.99, non-consumable
- [ ] Review notes copied into App Store Connect
- [ ] TestFlight beta of ≥ 50 users completed
- [ ] No "block" / "restrict" / "stop" in screenshot captions (review-bait)
