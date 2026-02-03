# Reference: Architecture

## Purpose
Project structure and patterns for adding new code.

## Directory Structure
```
CosmicCalendar/
├── App/                    # App entry, state, navigation
├── Models/                 # Data structures (SwiftData)
├── Services/               # Business logic, external APIs
├── Views/                  # SwiftUI views by feature
└── Theme/                  # Styling (colors, typography, components)
```

## Key Files
| File | Purpose |
|------|---------|
| `App/CosmicCalendarApp.swift` | App entry point, ModelContainer setup |
| `App/AppState.swift` | Global observable state |
| `App/ContentView.swift` | Root view, onboarding vs main flow |
| `App/MainTabView.swift` | Tab navigation (Today, Calendar, Settings) |

## Patterns

### MVVM
- Views observe state via `@StateObject`, `@EnvironmentObject`
- Services handle business logic, are stateless
- Models are plain data structures

### SwiftData
- `User` is the only persisted model currently
- ModelContainer configured in `CosmicCalendarApp`
- Use `@Query` in views or `modelContext` in services

### Adding New Features
1. Create view in appropriate `Views/` subdirectory
2. Add model to `Models/` if new data structure needed
3. Add service to `Services/` if new business logic needed
4. Wire into navigation in `MainTabView` or parent view
