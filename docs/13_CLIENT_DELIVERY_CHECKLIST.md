# 13 — Client Delivery Checklist

**Status:** Planning document. Everything required before handing the platform to an enterprise client for a given tenant. Executed as Phase 29 (`03_DEVELOPMENT_PHASES.md`). Every section has a responsible role; every item must be checked (or explicitly marked N/A with justification) before sign-off.

---

## 1. Build Verification

- [ ] `apps/storefront` builds successfully: Android debug + release (`.apk`/`.aab`).
- [ ] `apps/storefront` builds successfully: iOS debug + release (`.ipa`), signed with the client's provisioning profile.
- [ ] `apps/storefront` builds successfully: Web release (optimized, tree-shaken).
- [ ] `apps/admin` builds successfully: Web release.
- [ ] `apps/admin` builds successfully: Desktop targets, if the client requires a native admin desktop app (optional — confirm scope).
- [ ] `melos run analyze` passes with zero errors/warnings across the entire workspace.
- [ ] `melos run test` passes with 100% of existing unit/`bloc_test` suites green.
- [ ] Release builds run in `dataSourceMode = mock` with Developer Mode/Tenant Switcher confirmed absent (per `12_MANUAL_TEST_PLAN.md` §23).
- [ ] App size (mobile) and initial bundle size (web) recorded and within an agreed acceptable range.

**Responsible:** Engineering Lead.

## 2. Manual Testing

- [ ] Full `12_MANUAL_TEST_PLAN.md` executed against the final release-candidate build for the target tenant.
- [ ] Zero open Critical severity defects.
- [ ] Zero open High severity defects (or explicit, documented client-accepted exceptions).
- [ ] Medium/Low severity defects logged with a triage decision (fix now / backlog) recorded.
- [ ] Regression pass completed after any post-QA defect fixes.

**Responsible:** QA Lead.

## 3. Documentation

- [ ] All 14 documents in `docs/` reconciled against the as-built system (Phase 28.3).
- [ ] Any deviations from the original plan recorded as ADRs in `docs/adr/` and cross-referenced.
- [ ] `14_IMPLEMENTATION_PROGRESS.md` shows 100% 🟩 Completed for all in-scope milestones.
- [ ] A client-facing README (deployment/runbook summary) is prepared, separate from the internal architecture docs, if the client's engineering team will operate the platform post-handoff.
- [ ] API/repository contracts intended for the future backend-integration phase are documented and handed off if that phase is contracted separately.

**Responsible:** Technical Project Manager.

## 4. Branding

- [ ] Client-provided brand guideline (colors, logo, typography, tone of voice) reviewed and mapped into `TenantConfig.branding`.
- [ ] Branding Editor (`07_SCREEN_CATALOG.md` §T) used to configure and preview the client's actual branding, not the default/demo tenant's.
- [ ] Contrast-check warning (if any) reviewed and explicitly accepted or resolved with the client.
- [ ] App name, app icon, and splash screen reflect the client's branding on every platform (mobile launcher icon, web favicon/title, admin panel title).
- [ ] Copy overrides (support email, empty-state text, error messaging tone) reviewed against `TenantConfig.copyOverrides` for client-appropriate language.

**Responsible:** UI/UX Architect + Client Stakeholder.

## 5. Assets

- [ ] Client logo delivered in all required formats/resolutions (app icon per platform spec, web favicon, admin panel header logo).
- [ ] Onboarding illustrations/empty-state illustrations either use client-approved defaults or client-specific replacements.
- [ ] Product imagery pipeline confirmed (even though Phase 1 uses mock data, confirm the intended real-image hosting/CDN strategy is documented for the next phase).
- [ ] Fonts licensed appropriately if the client requires a custom typeface beyond the platform's default font family.

**Responsible:** UI/UX Architect.

## 6. Firebase

- [ ] Firebase project(s) provisioned for `dev`/`staging`/`prod` per `11_ENVIRONMENT_CONFIGURATION.md` §9 (even if not yet wired to live calls in this delivery).
- [ ] `firebase_options.dart` and platform config files (`google-services.json`, `GoogleService-Info.plist`) placed per environment, or explicitly deferred with a documented follow-up owner if Firebase integration is a separately contracted phase.
- [ ] Firestore collection map (`10_DATA_FLOW.md` §7) reviewed and approved as the target schema for the future integration phase.
- [ ] Firebase project billing/ownership transferred to or shared appropriately with the client's account, per contractual agreement.

**Responsible:** DevOps Engineer.

## 7. App Store (iOS)

- [ ] Apple Developer account access confirmed (client-owned or agency-managed, per contract).
- [ ] App Store Connect listing created: name, description, keywords, category, age rating.
- [ ] Screenshots prepared for all required device sizes, reflecting the client's actual branding (not default tenant).
- [ ] Privacy Nutrition Label completed accurately based on actual data collected (note: Phase 1 mock data collects nothing real; update this before any Firebase-integrated release).
- [ ] App Privacy Policy and Terms of Service URLs provided by the client and linked in-app (Settings/Support) and in the store listing.
- [ ] TestFlight build distributed for client UAT before public submission.
- [ ] Submission for App Store review completed; review feedback (if any) triaged.

**Responsible:** DevOps Engineer + Client Stakeholder.

## 8. Play Store (Android)

- [ ] Google Play Console access confirmed (client-owned or agency-managed).
- [ ] Play Store listing created: name, description, category, content rating questionnaire completed.
- [ ] Screenshots and feature graphic prepared reflecting client branding.
- [ ] Data Safety section completed accurately.
- [ ] Internal testing / closed testing track used for client UAT before production rollout.
- [ ] Signed release `.aab` uploaded; staged rollout percentage agreed with the client for initial release.

**Responsible:** DevOps Engineer + Client Stakeholder.

## 9. Web Deployment (Storefront)

- [ ] Hosting target selected and provisioned (e.g., Firebase Hosting, per the `firebase-hosting-basics` capability) with the client's custom domain.
- [ ] SSL/TLS certificate active and verified on the custom domain.
- [ ] Web build deployed from the `prod` flavor with correct `TenantConfig` baked in or runtime-resolved per the client's tenant.
- [ ] SEO essentials verified: page titles, meta description, favicon, robots.txt (to the extent applicable for a primarily-app-shell SPA).
- [ ] Web performance spot-checked (Lighthouse or equivalent) for an acceptable baseline score, recorded for future comparison.
- [ ] Deep links/direct URL entry verified working on the deployed domain (not just localhost), per `09_ROUTING_PLAN.md` §5.

**Responsible:** DevOps Engineer.

## 10. Admin Deployment

- [ ] Admin Panel hosting target provisioned, typically on a distinct subdomain (e.g., `admin.client-domain.com`) from the storefront.
- [ ] Access to the Admin Panel restricted appropriately (e.g., not indexed by search engines; consider additional network-level restriction if required by the client's security policy).
- [ ] Initial SuperAdmin account(s) provisioned for the client's operations team, with a secure first-login/password-reset flow completed.
- [ ] Role assignments (CatalogManager, OrderManager, MarketingManager, SupportAgent) configured per the client's actual team structure.

**Responsible:** DevOps Engineer + Client Stakeholder.

## 11. Production Configuration

- [ ] `prod` flavor's `AppConfig` verified: `dataSourceMode`, log level, maintenance flags all correct for go-live.
- [ ] `TenantConfig` for the client finalized and loaded correctly in the `prod` build (verify branding/copy/feature flags all resolve as configured, not falling back to `default_tenant`).
- [ ] Feature flags reviewed with the client and set to their contracted feature set (e.g., a client not licensing Wishlist has it disabled and confirmed absent from nav/routes).
- [ ] Maintenance mode flags confirmed OFF for go-live (and the mechanism to enable them in an emergency is documented and accessible to the operations team).
- [ ] Crash reporting / logging sink connection point documented as ready for the future backend-integration phase (Phase 1 delivery uses local logging only — confirmed and communicated to the client, not silently assumed).

**Responsible:** DevOps Engineer.

## 12. Security

- [ ] Authentication flows (Login/Register/Password Reset/OTP) reviewed for standard security practices (no plaintext password logging, no user-enumeration leaks, rate-limit design documented for the future backend phase).
- [ ] Route guards (`09_ROUTING_PLAN.md` §4) manually verified to block unauthorized access to every protected and role-gated route via direct URL entry (Web).
- [ ] Admin RBAC verified: no role can escalate its own permissions via any exposed UI or route.
- [ ] Sensitive data (payment method details, even mocked) confirmed masked everywhere in the UI and never written to logs.
- [ ] Developer Mode, Tenant Switcher, and Developer Panel confirmed completely inaccessible in the `prod`-flavor build (re-confirmed here in addition to `12_MANUAL_TEST_PLAN.md` §23, as this is a security-relevant gate, not just a QA item).
- [ ] Dependency audit performed (`flutter pub outdated` / known-vulnerability check) with no unresolved critical advisories in shipped dependencies.
- [ ] Firebase security rules drafted and reviewed (even if not yet enforced against live traffic in this delivery) as a deliverable for the next phase, using the `firebase-security-rules-auditor` capability once Firestore integration begins.

**Responsible:** Lead Software Architect + DevOps Engineer.

## 13. Multi-Tenant / White-Label Proof

- [ ] Phase 26.3 rebrand verification (second demo tenant, zero code changes) result attached/referenced as evidence.
- [ ] Client's specific tenant configuration reviewed end-to-end (branding, copy, feature flags) as a final proof-of-fit before go-live, distinct from the generic demo-tenant proof.

**Responsible:** Product Architect.

## 14. Final Sign-Off

| Section | Responsible Role | Status | Signed By | Date |
|---|---|---|---|---|
| Build Verification | Engineering Lead | | | |
| Manual Testing | QA Lead | | | |
| Documentation | Technical Project Manager | | | |
| Branding | UI/UX Architect | | | |
| Assets | UI/UX Architect | | | |
| Firebase | DevOps Engineer | | | |
| App Store | DevOps Engineer | | | |
| Play Store | DevOps Engineer | | | |
| Web Deployment | DevOps Engineer | | | |
| Admin Deployment | DevOps Engineer | | | |
| Production Configuration | DevOps Engineer | | | |
| Security | Lead Software Architect | | | |
| Multi-Tenant/White-Label Proof | Product Architect | | | |

**Client handoff does not occur until every row above is signed off.**
