# Feature: Onboarding

## Purpose
Collect user birth data and generate initial natal chart.

## Files (modify these)
- `Views/Onboarding/WelcomeView.swift` - entry screen, app introduction
- `Views/Onboarding/BirthDataInputView.swift` - birth date/time/location form
- `Views/Onboarding/ChartRevealView.swift` - animated chart reveal

## Dependencies (read-only context)
- `Models/User.swift` - stores birth data via SwiftData
- `Models/BirthChart.swift` - calculated natal chart structure
- `Services/EphemerisService.swift` - calculates chart from birth data
- `Services/LocationService.swift` - location search/geocoding

## State
- `AppState.hasCompletedOnboarding` - controls whether to show onboarding
- User model persisted via SwiftData `ModelContainer`

## Flow
1. WelcomeView → tap to continue
2. BirthDataInputView → enter birth details
3. ChartRevealView → see calculated chart → proceed to main app

## Current Status
- [x] Welcome carousel (4 pages with skip)
- [x] Birth date picker (graphical)
- [x] Birth time toggle + wheel picker
- [x] Location search with geocoding
- [x] Chart reveal animation
- [x] User save to SwiftData
- [ ] "Birth time unknown" tooltip explanation
- [ ] Timezone confirmation display
- [ ] Location autocomplete improvements
