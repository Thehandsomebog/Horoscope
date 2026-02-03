# Feature: Settings

## Purpose
User preferences, notification controls, profile management.

## Files (modify these)
- `Views/Settings/SettingsView.swift` - main settings screen
- `Views/Settings/NotificationPreferencesView.swift` - notification controls

## Dependencies (read-only context)
- `Models/User.swift` - user profile data
- `Services/NotificationService.swift` - push notification management
- `App/AppState.swift` - app-wide settings

## Sections
1. Profile - view/edit birth data (re-triggers onboarding flow)
2. Notifications - daily reminder time, event alerts
3. Display - theme preferences (future)
4. About - app version, links

## State
- User model for profile data
- UserDefaults for preferences
- NotificationService for push permissions

## Current Status
- [x] Profile section (avatar, name, sun sign)
- [x] Birth data display (date, time, location)
- [x] Notification preferences sheet
- [x] Morning briefing toggle + time picker
- [x] Retrograde/moon phase alert toggles
- [x] About section (version, links)
- [x] Reset all data with confirmation
- [ ] Edit birth data flow
- [ ] Theme toggle (dark mode)
- [ ] Export data option
- [ ] Real privacy policy/terms URLs
