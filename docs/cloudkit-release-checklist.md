# CloudKit release checklist — Hero: Einbürgerungstest v2.3

Complete before submitting build **2.3 (12+)** to App Store review.

## Xcode & signing

- [ ] Target **Signing & Capabilities** includes **iCloud** → **CloudKit**
- [ ] Container `iCloud.com.gizatech.Leben-in-Deutschland` is enabled
- [ ] `Leben in Deutschland.entitlements` matches the container above
- [ ] Test on a physical device signed into iCloud (simulator sync is limited)

## CloudKit Console

- [ ] Open [CloudKit Console](https://icloud.developer.apple.com/) → container `iCloud.com.gizatech.Leben-in-Deutschland`
- [ ] Validate **Development** schema after running the app (record types created by SwiftData):
  - `CD_QuestionStatisticsRecord` (or SwiftData-generated equivalents)
  - `CD_LearningAnswerRecord`
  - `CD_FavoriteQuestion`
  - `CD_UserProgressProfile`
- [ ] **Deploy Schema to Production** after Development schema is correct
- [ ] **Production → Indexes**: verify `recordName` (and any fields used in queries) is **Queryable**
  - Missing queryable indexes can cause **silent sync failures** in production

## Functional smoke tests

| Scenario | Expected |
|----------|----------|
| Fresh install, iCloud on | Empty progress; study → data persists locally |
| Upgrade from 2.2 with UserDefaults progress | One-time migration; stats visible; no duplicate rows |
| Reinstall on same Apple ID | Cloud data wins; migration skips existing `recordId`s |
| iPhone → iPad (same Apple ID) | Progress appears after sync; UI updates without restart |
| Change Bundesland | Loads that state’s progress; other states retained |
| Not signed into iCloud | Local progress works; no crash |
| Settings → Reset App | All states cleared locally; syncs deletion via CloudKit |
| Freemium limits | Still per device (UserDefaults); unchanged |

## Documentation & store

- [ ] Publish updated FAQ on website (`docs/faq-en.txt` → site FAQ)
- [ ] Merge iCloud section into privacy policy (`docs/privacy-policy-icloud-section.txt`)
- [ ] Paste App Review notes (`docs/app-review-notes-v2.3.txt`)
- [ ] README reflects SwiftData + CloudKit sync

## Version

- Marketing version: **2.3**
- Build: **12** (increment for each App Store upload)
