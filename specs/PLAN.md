# Implementation Plan: Cosmic Calendar

**Goal:** Ship to App Store
**Last Updated:** 2026-02-02

---

## Status Summary

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Core MVP | Complete | 100% |
| Phase 2: Polish & UX | In Progress | 20% |
| Phase 3: App Store Prep | Not Started | 0% |
| Phase 4: Testing | In Progress | 25% |
| Phase 5: Launch | Not Started | 0% |

---

## Phase 1: Core MVP
**Status: COMPLETE**

All core functionality is implemented and working.

- [x] App structure (entry point, state, navigation)
- [x] Onboarding flow (welcome, birth data input, chart reveal)
- [x] User persistence (SwiftData)
- [x] Today view (score, moon phase, domains, recommendations)
- [x] Calendar view (month grid, day selection, score indicators)
- [x] Day detail view (full cosmic report)
- [x] Settings view (profile display, notifications, reset)
- [x] Ephemeris calculations (fallback algorithm)
- [x] Cosmic score calculator
- [x] Recommendation engine
- [x] Notification service (morning briefing, alerts)
- [x] Location search (geocoding)
- [x] Theme system (colors, typography, components)

---

## Phase 2: Polish & UX
**Status: IN PROGRESS**

**Spec:** [onboarding.md](onboarding.md), [calendar.md](calendar.md), [today-view.md](today-view.md), [settings.md](settings.md)

### Onboarding
- [ ] Add "birth time unknown" explanation tooltip
- [ ] Improve location autocomplete UX (show loading states better)
- [ ] Add timezone display confirmation

### Today View
- [ ] Add pull-to-refresh
- [ ] Add haptic feedback on score reveal
- [ ] Animate domain score bars on appear

### Calendar
- [ ] Add month navigation swipe gesture
- [ ] Add cosmic event indicators (eclipses, retrogrades)
- [ ] Cache calculated scores to avoid recalculation
- [ ] Add "jump to today" button

### Settings
- [ ] Implement edit birth data flow
- [ ] Add export data option
- [ ] Add theme toggle (light/dark)

### General
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Add haptic feedback throughout
- [ ] Dark mode support

---

## Phase 3: App Store Prep
**Status: NOT STARTED**

**Spec:** [architecture.md](architecture.md), [design-system.md](design-system.md)

### Assets
- [ ] Design final app icon (1024x1024)
- [ ] Create launch screen
- [ ] Generate App Store screenshots (6.7", 6.5", 5.5")
- [ ] Create App Store preview video (optional)

### Legal
- [ ] Write privacy policy (host on real URL)
- [ ] Write terms of service (host on real URL)
- [ ] Update SettingsView links to real URLs

### Metadata
- [ ] Write App Store description
- [ ] Choose keywords
- [ ] Set age rating
- [ ] Configure In-App Purchases (if any)

### Technical
- [ ] Configure App Store Connect
- [ ] Set up provisioning profiles
- [ ] Archive and validate build
- [ ] Submit for review

---

## Phase 4: Testing
**Status: IN PROGRESS**

### Unit Tests
- [x] Test CosmicScoreCalculator (35 tests covering score clamping, moon phases, retrogrades, domains, aspects)
- [ ] Test EphemerisService calculations
- [ ] Test RecommendationEngine
- [ ] Test User model
- [ ] Test date/timezone handling

### UI Tests
- [ ] Test onboarding flow completion
- [ ] Test calendar navigation
- [ ] Test settings reset flow

### Manual Testing
- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPhone 15 Pro Max (large screen)
- [ ] Test on iPad (if supporting)
- [ ] Test with VoiceOver
- [ ] Test with Dynamic Type sizes
- [ ] Test notification delivery

---

## Phase 5: Launch
**Status: NOT STARTED**

- [ ] Submit to App Store Review
- [ ] Address any review feedback
- [ ] Plan launch marketing
- [ ] Monitor crash reports post-launch
- [ ] Gather user feedback

---

## Known Technical Debt

| Issue | Priority | Notes |
|-------|----------|-------|
| Ephemeris accuracy | Medium | Using simplified fallback calculations (SwissEphemeris removed) |
| No score caching | Low | Recalculates on every view appear |
| No analytics | Medium | Need to track usage for iteration |
| No crash reporting | High | Add before launch |

---

## File-to-Spec Mapping

| Feature Area | Spec File | Primary Code Files |
|--------------|-----------|-------------------|
| Onboarding | [onboarding.md](onboarding.md) | `Views/Onboarding/*` |
| Calendar | [calendar.md](calendar.md) | `Views/Calendar/*` |
| Today | [today-view.md](today-view.md) | `Views/Today/*` |
| Settings | [settings.md](settings.md) | `Views/Settings/*` |
| Scoring | [scoring.md](scoring.md) | `Services/CosmicScoreCalculator.swift` |
| Design | [design-system.md](design-system.md) | `Theme/*` |
| Architecture | [architecture.md](architecture.md) | `App/*`, `Models/*`, `Services/*` |
