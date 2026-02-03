# Reference: Cosmic Scoring

## Purpose
Algorithm for calculating daily cosmic scores (1-10 scale).

## Files
- `Services/CosmicScoreCalculator.swift` - implementation

## Algorithm

### Base Calculation
- **Base Score**: 5.0 (neutral starting point)
- **Final Range**: 1-10 (always clamped)

### Moon Phase Modifiers
| Phase | Modifier |
|-------|----------|
| Full Moon | +1.0 |
| New Moon | +0.5 |
| Waning | -0.5 |

### Retrograde Penalties
| Planet | Modifier |
|--------|----------|
| Mercury | -1.5 |
| Venus | -1.0 |
| Mars | -0.5 |

### Transit Aspects
- Beneficial (trine, sextile): +0.5 to +1.5
- Challenging (square, opposition): -0.5 to -1.5
- Exact aspects stronger than applying/separating

## Domain Weights
Each domain uses same base algorithm but weights planets differently:
- **Relationships**: Venus, Moon weighted higher
- **Career**: Saturn, Jupiter weighted higher
- **Health**: Mars, Moon weighted higher

## Rules
- All scores MUST be clamped to 1-10
- Never return raw unclamped values to UI
