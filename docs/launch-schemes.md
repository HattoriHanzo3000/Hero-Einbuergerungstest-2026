# Launch Schemes (DEBUG)

Xcode schemes seed app state at launch via the `LID_LAUNCH_PROFILE` environment variable. Implementation lives in `LaunchConfiguration.swift` (DEBUG builds only).

## Regenerate schemes

After changing profiles in `LaunchConfiguration.swift`, update the scheme list in `Scripts/generate_launch_schemes.rb` if needed, then run:

```bash
ruby Scripts/generate_launch_schemes.rb
```

Commit the generated `.xcscheme` files under `Leben in Deutschland.xcodeproj/xcshareddata/xcschemes/`.

## Scheme catalog

| Scheme | Profile | Opens to |
|--------|---------|----------|
| **LiD Default** | `default` | Home — DE UI, RU translation, Berlin, Pro |
| LiD Pro EN / RU / TR / UK | `lang_en` … | Home — that UI language, DE translation, Berlin, Pro |
| LiD Onboarding (Fresh) | `onboarding_fresh` | Welcome video → onboarding |
| **LiD Free Launch Offer DE** | `launch_offer_de` | Free, active launch offer, DE UI + RU translation |
| **LiD Free Launch Offer EN/RU/TR/UK** | `launch_offer_en` … | Free, active launch offer, that UI language + DE translation |
| **LiD Free Paywall Limits DE** | `paywall_limits_de` | Free, expired launch offer, limits reached, DE + RU |
| **LiD Free Paywall Limits EN/RU/TR/UK** | `paywall_limits_en` … | Free, expired offer, limits reached, that language + DE |
| LiD State * (×16) | `state_<slug>` | Home — DE/RU, that Bundesland, Pro |

Federal state profile IDs: `state_baden_wuerttemberg`, `state_bayern`, `state_berlin`, … `state_thueringen`.

## Usage

1. Select a scheme in the Xcode toolbar (e.g. **LiD Default**).
2. Run on the simulator (⌘R).

Profiles re-apply on every launch. Onboarding scheme clears onboarding-related `UserDefaults` each run but does not wipe SwiftData progress.

## Notes

- **Pro status** uses `DebugOverrides.simulatePro`, not StoreKit Configuration.
- **Launch offer** uses `first_launch_date` (72h window via `LaunchOfferService`).
- **Release builds** ignore `LID_LAUNCH_PROFILE`.
- **CI** uses scheme **LiD Default**.
