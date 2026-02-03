# Project: Cosmic Calendar

## What
- Tech stack: Swift, SwiftUI, SwiftData, SwissEphemeris
- Structure: MVVM with Services layer
- Entry point: `CosmicCalendarApp.swift`

## Why
- Purpose: iOS app helping women make life decisions using astrological data
- Key domains: Relationships, Career, Health via cosmic scoring

## How
- Run: Open in Xcode, Cmd+R
- Test: Cmd+U (XCTest)
- Build: `xcodebuild` or Xcode archive
- Lint: SwiftLint (if configured)

## Specs
- **`specs/PLAN.md`** - Master plan with phased milestones and TODO checklists
- **`specs/README.md`** - Index of all feature and reference specs

Before modifying a feature, read its spec to find the right files.

## Rules
- Use SwiftUI for all views, no UIKit
- All ephemeris calls go through EphemerisService
- Scores must be 1-10 scale, clamped
- Never store sensitive birth data unencrypted
- Follow warm/feminine design system in docs/design-system.md
