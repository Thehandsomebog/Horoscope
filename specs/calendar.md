# Feature: Calendar

## Purpose
Display monthly calendar with cosmic scores per day, drill into day details.

## Files (modify these)
- `Views/Calendar/CalendarView.swift` - main calendar grid
- `Views/Calendar/DayDetailView.swift` - single day cosmic report
- `Views/Calendar/CosmicScoreIndicator.swift` - visual score widget (1-10)

## Dependencies (read-only context)
- `Models/CosmicDay.swift` - daily cosmic data structure
- `Models/CosmicEvent.swift` - retrogrades, eclipses, etc.
- `Services/CosmicScoreCalculator.swift` - computes daily scores
- `Services/RecommendationEngine.swift` - activity recommendations

## State
- Selected date tracked in view
- CosmicDay data fetched/computed per visible month

## Flow
1. CalendarView shows month grid with score indicators
2. Tap day → DayDetailView with full cosmic report
3. DayDetailView shows scores by domain + recommendations

## Current Status
- [x] Month grid with weekday headers
- [x] Month navigation (prev/next buttons)
- [x] Day selection with score preview card
- [x] Score color indicators per day
- [x] DayDetailView sheet with full report
- [x] Planetary positions display
- [x] Flow layout for moon activities
- [ ] Month swipe navigation gesture
- [ ] Cosmic event indicators (eclipses, retrogrades)
- [ ] Score caching
- [ ] "Jump to today" button
