# CloudKit schema — QuestionFeedback (step 1)

Question reports are stored in the **public** CloudKit database. This is separate from SwiftData progress sync (private database).

**Container:** `iCloud.com.gizatech.Leben-in-Deutschland`  
**Record type:** `QuestionFeedback`  
**Schema file:** [`CloudKit/QuestionFeedback.ckdb`](../CloudKit/QuestionFeedback.ckdb)

---

## Option A — Import with cktool (recommended)

1. **Save a management token** (once per machine, or when you see “Session has expired”):
   ```bash
   ./Scripts/cktool_save_management_token.sh
   ```
   When the browser opens:
   - Sign in with your **Apple Developer** account (team `SZQ626NP5U`)
   - Generate a **management** token (not a user token)
   - Copy it and paste into Terminal when prompted

   Manual equivalent:
   ```bash
   xcrun cktool save-token --type management --force
   ```

2. **Import into Development:**
   ```bash
   ./Scripts/import_question_feedback_schema.sh
   ```

3. **Verify** in [CloudKit Console](https://icloud.developer.apple.com/):
   - Container → **Development** → **Schema** → record type `QuestionFeedback`
   - Confirm fields and security roles below match

4. After app code is integrated and a test report appears under Development → Data → Public Database, deploy to Production (see [Production deploy](#production-deploy-after-testing)).

### Troubleshooting cktool

| Symptom | Cause | Fix |
|---------|--------|-----|
| “Session has expired or is invalid” | Old or wrong token | Run `./Scripts/cktool_save_management_token.sh` |
| “No management token found” | Token never saved or was removed | Same as above |
| You chose **user** token earlier | User tokens cannot import schema | Save again with `--type management` |
| Browser flow is confusing | — | Use **Option B** (CloudKit Console manual setup) instead — no terminal token needed |

---

## Option B — CloudKit Console (manual)

1. Open [CloudKit Console](https://icloud.developer.apple.com/) → `iCloud.com.gizatech.Leben-in-Deutschland`.
2. Select **Development** → **Schema** → **Record Types** → **+** → name: `QuestionFeedback`.
3. Add fields:

| Field | Type | Index |
|-------|------|-------|
| `questionId` | String | Queryable |
| `questionText` | String | — |
| `category` | String | — |
| `feedbackType` | String | Queryable |
| `message` | String | — |
| `userEmail` | String | — |
| `deviceInfo` | String | — |
| `appVersion` | String | — |
| `language` | String | — |
| `submittedAt` | Date/Time | Queryable, Sortable |

4. **Security** (public database, `QuestionFeedback`):
   - **Create:** `_icloud` (authenticated iCloud users)
   - **Write:** `_creator`
   - **Read:** do **not** grant `_world` (reports are developer-only via Console)

5. **Indexes** (after record type exists):
   - Queryable: `submittedAt`, `questionId`, `feedbackType`
   - Sortable: `submittedAt` (descending when browsing in Console)

---

## Field semantics

| Field | Source in app |
|-------|----------------|
| `questionId` | Reported question ID |
| `questionText` | Question text (truncated to 4000 chars in app) |
| `category` | Question category |
| `feedbackType` | `question_error`, `question_unclear`, `answer_incorrect`, `translation_issue`, `other` |
| `message` | User description (required) |
| `userEmail` | Optional contact email |
| `deviceInfo` | e.g. `iPhone iOS 18.x` |
| `appVersion` | e.g. `2.3 (11)` |
| `language` | App language code (`de`, `en`, …) |
| `submittedAt` | Submission timestamp |

Swift constants: [`QuestionFeedbackCloudKitSchema.swift`](../Leben%20in%20Deutschland/00%20-%20Core/05%20-%20Constants/QuestionFeedbackCloudKitSchema.swift)

---

## Where you read reports

CloudKit Console → **Development** or **Production** → **Data** → **Public Database** → **QuestionFeedback**

Sort by `submittedAt` or `___createTime` to see newest first.

---

## Production deploy (after testing)

1. Confirm test records in **Development** → Public Database.
2. Open [CloudKit Console](https://icloud.developer.apple.com/) → container → **Deploy Schema to Production**.
   - cktool `import-schema` works only for **Development**; Production uses the Console deploy action.
3. Submit one test report from a **Release** build and verify under **Production** → Public Database → `QuestionFeedback`.
4. Check off items in [`cloudkit-release-checklist.md`](cloudkit-release-checklist.md).
