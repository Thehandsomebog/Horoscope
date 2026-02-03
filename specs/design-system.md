# Reference: Design System

## Purpose
Visual styling standards for consistent UI.

## Files
- `Theme/Colors.swift` - color palette
- `Theme/Typography.swift` - font styles
- `Theme/Components.swift` - reusable UI components

## Colors
| Name | Hex | Usage |
|------|-----|-------|
| Primary | #E8B4BC | Soft rose - main brand color |
| Secondary | #FFF5E6 | Warm cream - cards, surfaces |
| Accent | #C4A4C4 | Dusty lavender - highlights |
| Background | #FFFAF5 | Off-white - app background |
| Text | #4A4045 | Warm charcoal - body text |
| Cosmic | #D4AF37 | Soft gold - special accents |

## Principles
- Warm, feminine aesthetic throughout
- Soft gradients over hard edges
- Cosmic/celestial imagery where appropriate
- Maintain accessibility contrast ratios

## Rules
- Always use `Theme/Colors.swift` constants, never hardcode hex
- Use `Theme/Components.swift` for buttons, cards, etc.
- Follow typography scale from `Theme/Typography.swift`
