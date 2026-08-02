# Phase 7 — Authentication Manual Test Cases

**Branch:** `phase/7-authentication`  
**PR:** https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/5  
**Gate:** Merge into `develop` only when **every** case below is `Pass` (or explicitly `N/A` with reason).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / Chrome admin / iOS simulator |
| Build / commit | `edd2503` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P7-S04 Fail — …`). I will fix failures, then you re-run only the failed IDs.

---

## Prerequisites

### Run storefront (dev)

```bash
cd /Users/muneerahamed/Documents/E-Com-Buisness
fvm install
melos bootstrap   # first time / after pubspec changes

cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

### Run admin (dev, Web recommended)

```bash
cd /Users/muneerahamed/Documents/E-Com-Buisness/apps/admin
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env \
  -d chrome
```

### Demo credentials (mock — not Firebase)

| Role | Email | Password |
|---|---|---|
| Customer | `noah.patel02@example.com` | `Password123!` |
| Admin | `admin@example.com` | `Password123!` |
| Support | `support@example.com` | `Password123!` |

- Mock OTP (always): `123456`  
- Auth is **100% mock** in Phase 7 (`MockAuthRemoteDataSource` + `SharedPreferences` session). No Firebase Auth calls.

### Clean-slate tip

To re-test onboarding / logged-out splash: clear app data / uninstall, or clear site data for the Flutter web origin, then relaunch.

---

## A. Storefront — Splash & onboarding

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-S01 | First launch → onboarding | Fresh install / cleared data → launch storefront | Splash briefly, then **Onboarding** (not Login, not Home) | ⬜ | |
| P7-S02 | Complete onboarding | On onboarding, finish or skip to continue | Lands on **Login** | ⬜ | |
| P7-S03 | Returning user (onboarding seen, logged out) | After P7-S02, kill app, relaunch (still logged out) | Splash → **Login** (skips onboarding) | ⬜ | |

---

## B. Storefront — Login & register

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-S04 | Valid customer login | Login with `noah.patel02@example.com` / `Password123!` | Success → **Home** (shell). No crash. | ⬜ | |
| P7-S05 | Invalid password | Login with correct email, wrong password | **Inline** error on form; stay on Login; no Home | ⬜ | |
| P7-S06 | Unknown email | Login with `nobody@example.com` / `Password123!` | Inline error; stay on Login | ⬜ | |
| P7-S07 | Weak password blocked on register | Open Register; enter new email; weak password (e.g. `123`) | Strength indicator weak; submit blocked or validation error | ⬜ | |
| P7-S08 | Register new account | Register unique email + strong password (≥ policy) + required fields | Session created → **Home** (or documented next step) | ⬜ | |
| P7-S09 | Duplicate email register | Register again with same email as P7-S08 | Clear inline error; no second account / no silent success | ⬜ | |
| P7-S10 | Customer cannot use admin login | Open admin app; try customer email on `/admin/login` | Inline unauthorized / blocked; **not** admin dashboard | ⬜ | |

---

## C. Storefront — Forgot password & OTP

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-S11 | Forgot password → OTP | From Login → Forgot Password → enter `noah.patel02@example.com` → continue | Moves to **OTP** screen (no account enumeration crash) | ⬜ | |
| P7-S12 | Wrong OTP | Enter OTP `000000` → submit | Inline error; stay on OTP | ⬜ | |
| P7-S13 | Correct OTP | Enter OTP `123456` → submit | Proceeds to reset-password (or success path per UI) | ⬜ | |
| P7-S14 | Reset then login | After OTP, set a new password if prompted, then login with new password (or original mock password if reset only validates flow) | Can reach Home again | ⬜ | |
| P7-S15 | Forgot with unknown email | Enter `unknown@example.com` on forgot | Neutral success-style message (no “user not found” leak) **or** documented mock behavior — note actual copy | ⬜ | |

---

## D. Storefront — Session, logout, guards

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-S16 | Session persists across restart | Login successfully → fully quit app → relaunch | Splash → **Home** (skips Login) | ⬜ | |
| P7-S17 | Logout clears session | From Profile (or available logout control) → Logout | Session cleared → **Login**; back navigation does not restore Home without login | ⬜ | |
| P7-S18 | Guard after logout | After logout, try opening a protected deep link / wishlist if gated | Redirected to **Login** | ⬜ | |
| P7-S19 | Dev panel still reachable in dev | While logged in (or out), open `/dev-panel` in dev flavor | Developer panel loads (Phase 6); auth still works after | ⬜ | |

---

## E. Admin — Login & session

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-A01 | Admin splash / login landing | Launch admin (cleared session) | Lands on **Admin Login** (or splash → admin login) | ⬜ | |
| P7-A02 | Valid admin login | `admin@example.com` / `Password123!` | Success → **Admin Dashboard** shell | ⬜ | |
| P7-A03 | Invalid admin password | Wrong password for admin email | Inline error; stay on login | ⬜ | |
| P7-A04 | Support login | `support@example.com` / `Password123!` | Enters admin shell (dashboard or allowed home) | ⬜ | |
| P7-A05 | Admin session persists | Login admin → quit → relaunch | Skips login → dashboard (or authenticated shell) | ⬜ | |
| P7-A06 | Admin logout | Logout from admin | Back to admin login; session cleared | ⬜ | |
| P7-A07 | Admin forgot / OTP (if wired) | Forgot password on admin login → OTP `123456` | Same mock OTP path works on admin routes | ⬜ | |

---

## F. Smoke / regression (quick)

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P7-R01 | Storefront shell nav after login | After P7-S04, tap bottom nav destinations | Tabs switch without forced logout | ⬜ | |
| P7-R02 | Admin shell nav after login | After P7-A02, open a few side-nav items | Navigate without crash / forced logout | ⬜ | |
| P7-R03 | No Firebase dependency | Confirm app runs offline / without Firebase project config | Login still works with mock credentials | ⬜ | |

---

## Sign-off

| Check | Status |
|---|---|
| All storefront cases Pass or justified N/A | ⬜ |
| All admin cases Pass or justified N/A | ⬜ |
| CI green on PR #5 | ⬜ |
| Ready to merge `phase/7-authentication` → `develop` | ⬜ |

**Tester sign-off:** ______________________  **Date:** __________

---

## Comment log (optional)

Paste chat-style notes here as you go:

```
P7-S04 Pass
P7-S05 Fail — error showed as snackbar instead of under password field
...
```
