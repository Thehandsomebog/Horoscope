# Feature: Today View

## Purpose
Show today's cosmic weather at a glance - scores, events, recommendations.

## Files (modify these)
- `Views/Today/TodayView.swift` - main today screen

## Dependencies (read-only context)
- `Models/CosmicDay.swift` - today's cosmic data
- `Models/CosmicEvent.swift` - active events (retrogrades, etc.)
- `Services/CosmicScoreCalculator.swift` - today's scores
- `Services/RecommendationEngine.swift` - today's recommendations
- `Theme/Components.swift` - reusable UI components

## State
- Today's CosmicDay computed on view appear
- Refreshes on app foreground

## Display Sections
1. Overall cosmic score (1-10)
2. Domain scores (Relationships, Career, Health)
3. Active cosmic events (retrogrades, moon phase)
4. Recommended activities for today

## Current Status
- [x] Greeting section (time-based)
- [x] Overall cosmic score with indicator
- [x] Moon phase card with description
- [x] Domain scores (Relationships, Career, Health)
- [x] Retrograde alert section
- [x] Recommendations section (top 3)
- [x] Loading state
- [ ] Pull-to-refresh
- [ ] Haptic feedback on score reveal
- [ ] Domain score bar animations
