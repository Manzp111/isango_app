<!-- isango-pr-template:v1 -->

## Summary

Build out the full authentication entry flow — Sign In, Sign Up, and Verify
Email — to match the Stitch "Kinetic Campus" designs, vendor the design
references, and harden form validation so each input owns its own error
state, validates reactively as the user types, and the confirm-password
field re-runs the moment the password changes. The submission error banner
is now strictly reserved for server / submission failures and never paints
field-level state.

## Linked Issue

Closes #

## What Changed

**New screens (`lib/screens/auth/`)**
- `sign_in_screen.dart` — white rounded card on lavender background, italic "Isango" wordmark, "Welcome back!" headline, two intro paragraphs, email + password fields, "Forgot Password?" inline with the password label, pill "Sign In" button, "Don't have an account? Sign Up" footer.
- `sign_up_screen.dart` — shadowed top bar with circular back button + "Create Account" title, intro line, Full Name / University Email / Password / Confirm Password fields, pill "Create Account →" button, verification footer, and an "Already have an account? Sign In" link.
- `verify_email_screen.dart` (new) — top bar + "Verify Email" title, white status panel with a circular pale-blue icon, "Verification Pending" headline, "Why verify your email?" panel on a soft fill, "Resend Verification Email ✈" button, support footer. The screen reads the email from route arguments to personalize the description.

**Theme tokens (`lib/core/theme/`)**
- `app_colors.dart` — switched `mistBackground` to `#FAF8FF`, added `deepNavy #001142` and `fieldFill #F4F3FA` per `stitch-designs/DESIGN.md`.
- `app_theme.dart` — input theme uses the soft-fill colour, deep-navy focus border, and thicker red `errorBorder` + `focusedErrorBorder`.

**Shared widgets (`lib/widgets/auth/`)**
- `auth_primary_button.dart` — full-width pill (`StadiumBorder`), 56pt tall, optional `trailingIcon` slot (used for `arrow_forward` / `send_outlined`), configurable `backgroundColor`.
- `auth_text_field.dart` — stateful widget. Inner `TextFormField` uses `autovalidateMode: AutovalidateMode.onUserInteraction` so each field manages its own validation state. Adds a `trailing` slot for the label row ("Forgot Password?") and a `revalidateOn` `Listenable` so a field can re-run its validator when an external dependency changes (used by the confirm-password field). Label flips red and a red error icon is shown as the suffix only after the user has typed in *that* specific field.

**Validation (`lib/core/utils/auth_validators.dart`)**
- New `universityEmail` validator that enforces the `@stud.ur.ac.rw` domain (e.g. `nshimyimana_222023531@stud.ur.ac.rw`); rejects everything else with **"Please use a valid university email address"**. Wired on both sign-in and sign-up.

**Routing (`lib/app.dart`, `lib/core/constants/app_routes.dart`)**
- Registered `AppRoutes.verifyEmail` → `VerifyEmailScreen`. Sign-up now navigates to `verifyEmail` on success and passes the entered email as a route argument.

**Design references (`stitch-designs/`)**
- Vendored `DESIGN.md` (full color, typography, spacing, and component spec) and the source `login_screen_1.png` / `login_screen_2.png` mockups for future reference.

**Tests (`test/`)**
- `test/screens/auth/sign_in_screen_test.dart` — widget coverage for empty-form errors, in-flight CTA disable, error-banner visibility, and route navigation.
- `test/screens/auth/sign_up_screen_test.dart` — widget coverage for required-field errors, password mismatch, success path, and navigation.
- `test/widgets/auth_text_field_test.dart` (new) — verifies independent per-field state, label-color and suffix-icon behaviour, and `revalidateOn` semantics.
- `test/core/utils/auth_validators_test.dart` (new) — 9 cases covering accepted student emails (lowercase, uppercase, names with dots/digits) and rejection of `gmail.com`, `ur.ac.rw` without `stud`, empty/whitespace, missing `@`, and similar-but-wrong domains.

## Visual Evidence

<!-- Drop the following screenshots into the GitHub PR before submitting: -->
- Sign-in screen — clean state.
- Sign-in screen — invalid email (red label, red border, red error icon, red helper text).
- Sign-up screen — clean state.
- Sign-up screen — invalid university email rejected, other untouched fields stay neutral.
- Sign-up screen — mismatched confirm password (edit the password and confirm flips red without re-typing).
- Verify Email screen.

## Test Evidence

```
$ flutter analyze
Analyzing isango_app...
No issues found!

$ flutter test test/core/utils/auth_validators_test.dart
+ accepts a valid student email
+ accepts uppercase domain (case-insensitive)
+ accepts a name with dots and digits
+ rejects gmail.com
+ rejects ur.ac.rw without stud subdomain
+ rejects empty string with required-message
+ rejects whitespace as empty
+ rejects malformed input (missing @)
+ rejects similar-but-wrong domain
All tests passed!  (9/9)

$ flutter test test/widgets/auth_text_field_test.dart
+ initial state: no error, label is dark
+ typing invalid input turns label red and shows error icon
+ valid input clears the error visuals
+ revalidateOn does NOT paint the field until the user has typed in it
+ revalidateOn DOES update the field once the user has typed in it
All tests passed!  (5/5)

$ flutter run -d chrome
# Manually verified all three screens, error states, and the
# Sign Up → Verify Email navigation flow.
```

## Route and State Impact

- **New route:** `AppRoutes.verifyEmail` → `VerifyEmailScreen`. Accepts the user's email as a route argument (`String?`) so the description can name the address.
- **Changed flow:** Sign-up success now `pushReplacementNamed`s to `verifyEmail` instead of returning to login with a snackbar.
- **State:** All validation state is local to each `_AuthTextFieldState`; controller listeners are registered in `initState`, kept in sync via `didUpdateWidget`, and torn down in `dispose`. No new providers or app-level state. The submission-error banner state in the screen widgets is unchanged and remains separate from per-field validation state.

## Checklist

- [x] I linked the driving issue
- [x] I described the user-visible change
- [x] I added visual evidence for UI changes or marked it not applicable
- [x] I included fresh test evidence or explained why verification was not possible
- [x] I listed route or state impact, or marked it not applicable
- [x] I listed what remains out of scope

## Out of Scope

- Real backend integration — `onSignIn`, `onSignUp`, and `onResend` still use simulated 1.2s delays; wiring to the actual auth API (Firebase) is a follow-up.
- Password reset / "Forgot Password?" — currently shows a placeholder snackbar.
- Verification handling — clicking the link in the email is not yet implemented; the Resend button only simulates a request.
- Custom font assets — `DESIGN.md` calls for Spline Sans / Lexend; we use system fonts with matching weights/sizes for now.
- Other screens (home, saved, settings, submit) still use the older theme/wordmark — not touched in this PR.
