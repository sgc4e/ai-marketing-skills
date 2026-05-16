# Sprout (web)

A single-file web version of Sprout. No build step, no install, no Mac setup.

## How to use it on your Mac

1. Open Finder and navigate to `apps/Sprout/web/`
2. Double-click `index.html` — it opens in Safari or Chrome
3. That's it

## How to use it on your iPhone

Two options:

**Quick (works today)**: text the file to yourself, or upload `index.html` to any free static host (Vercel, Netlify, GitHub Pages — drag-and-drop), then open the URL in Safari on your phone.

**Add to home screen** (feels like an app):
1. Open the URL in Safari on your iPhone
2. Tap the share button (square with arrow up)
3. Scroll down and tap "Add to Home Screen"
4. The icon appears on your home screen — tap it like any app

## What it does

- Hatch one Sprout, give it a name
- Run a focus timer (5–60 min)
- If you switch tabs / lock your phone during a session, your Sprout droops and you get half credit
- Complete a session, watch your Sprout grow
- Tracks total focus minutes + day streak
- All data lives on your device in `localStorage` — clearing browser data resets everything
- Tap "Reset" in the footer to start over

## What it doesn't do (yet)

- Multiple Sprouts / species
- iCloud or cross-device sync
- Real app blocking
- Push notifications

Those are App Store features — for those we'd need the iOS version
(see `../docs/PRD.md` and the Swift code under `../App/`).
