# Model-Layer Audit And Evidence Checklist

## Summary

This checklist tracks model-layer implementation readiness for audit and evidence work.

It follows the current working boundary draft:

- `activity` is the Identity canonical evidence layer
- `journal` is the Global canonical history layer
- `chronicle` is the Regional detailed chronicle layer
- controller-level write points are out of scope for this phase

This file is intended for near-term implementation tracking. It is not the full design note. The
design note remains in `plans/analysis/audit-and-evidence-plan.md`.

## Scope

In scope for this checklist:

- event reference models
- event IDs and reference data
- activity, journal, and chronicle record models
- model-adjacent persistence rules
- model and service tests that prove write behavior

Out of scope for this checklist:

- controller write points
- request envelope completion
- API response contracts
- final regulator-facing retention policy
- full orchestration between global and regional flows

## Definition Of Done

Treat one checkbox as done only when all of the following are true for that event or rule:

- the event has a stable home in `activity`, `journal`, `chronicle`, or both
- the event ID exists as a model constant or documented fixed ID target
- reference data seeding or migration work is defined
- the write path is implemented in the model layer or model-adjacent service layer
- tests prove the expected persistence behavior

## Event Name Normalization Rule

Use model-style event names in this checklist.

- For existing event families, use the current constant form:
  - `UserActivityEvent::LOGGED_IN`
  - `StaffActivityEvent::TOKEN_REFRESHED`
  - `AppTimelineChronicleEvent::UPDATED`
- For planned event families that do not exist yet, use the intended future model-style form:
  - `MessageChronicleEvent::SENT`
  - `BillingChronicleEvent::CHARGE_CREATED`
  - `NotificationJournalEvent::DEVICE_REGISTERED`

This keeps the checklist aligned with model-layer implementation instead of free-form dotted names.

## Boundary And Invariants

- [ ] `activity` is documented as the Identity canonical evidence layer
- [ ] `journal` is documented as the Global canonical history layer
- [ ] `chronicle` is documented as the Regional detailed chronicle layer
- [ ] model-layer code does not use subdomain labels as the primary evidence ownership key
- [ ] model-layer code uses explicit event families instead of free-form event names
- [ ] activity event IDs are stable and fixed by constant or seeded reference row
- [ ] chronicle event IDs are stable and fixed by constant or seeded reference row
- [ ] each event family has a clear owning record base class
- [ ] event writes do not depend on controller-only context in this phase
- [ ] each write path has a clear failure policy
- [ ] each write path has a clear database destination
- [ ] cross-boundary events can be correlated later without renaming core event IDs
- [ ] acceptance rules distinguish `activity only`, `journal only`, `chronicle only`, and `both`

## Activity Only: User Identity And Security

- [ ] `UserActivityEvent::LOGGED_IN`
- [ ] `UserActivityEvent::LOGIN_FAILED`
- [ ] `UserActivityEvent::LOGGED_OUT`
- [ ] `UserActivityEvent::LOGIN_SUCCESS`
- [ ] `UserActivityEvent::TOKEN_REFRESHED`
- [ ] `UserActivityEvent::PASSKEY_REGISTERED`
- [ ] `UserActivityEvent::PASSKEY_REMOVED`
- [ ] `UserActivityEvent::TOTP_ENABLED`
- [ ] `UserActivityEvent::TOTP_DISABLED`
- [ ] `UserActivityEvent::STEP_UP_VERIFIED`
- [ ] `UserActivityEvent::RECOVERY_CODES_GENERATED`
- [ ] `UserActivityEvent::RECOVERY_CODE_USED`
- [ ] `UserActivityEvent::USER_SECRET_CREATED`
- [ ] `UserActivityEvent::USER_SECRET_REMOVED`
- [ ] `UserActivityEvent::USER_SECRET_UPDATED`
- [ ] `UserActivityEvent::ACCOUNT_RECOVERED`
- [ ] `UserActivityEvent::ACCOUNT_WITHDRAWN`
- [ ] `UserActivityEvent::AUTHORIZATION_FAILED`
- [ ] `UserActivityEvent::SIGNED_UP_WITH_EMAIL`
- [ ] `UserActivityEvent::SIGNED_UP_WITH_TELEPHONE`
- [ ] `UserActivityEvent::SIGNED_UP_WITH_GOOGLE`
- [ ] `UserActivityEvent::SIGNED_UP_WITH_APPLE`
- [ ] `UserActivityEvent::EMAIL_REMOVED`
- [ ] `UserActivityEvent::TELEPHONE_REMOVED`
- [ ] `UserActivityEvent::SOCIAL_UNLINKED`

## Activity Only: Staff Identity And Security

- [ ] `StaffActivityEvent::LOGGED_IN`
- [ ] `StaffActivityEvent::LOGIN_FAILED`
- [ ] `StaffActivityEvent::LOGGED_OUT`
- [ ] `StaffActivityEvent::LOGIN_SUCCESS`
- [ ] `StaffActivityEvent::TOKEN_REFRESHED`
- [ ] `StaffActivityEvent::AUTHORIZATION_FAILED`
- [ ] `StaffActivityEvent::STAFF_SECRET_CREATED`
- [ ] `StaffActivityEvent::STAFF_SECRET_REMOVED`
- [ ] `StaffActivityEvent::STAFF_SECRET_UPDATED`
- [ ] `StaffActivityEvent::STEP_UP_VERIFIED`

## Journal Only: Global Preference Root

- [ ] `AppPreferenceJournalEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `AppPreferenceJournalEvent::REFRESH_TOKEN_ROTATED`
- [ ] `AppPreferenceJournalEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `AppPreferenceJournalEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `AppPreferenceJournalEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `AppPreferenceJournalEvent::RESET_BY_USER_DECISION`
- [ ] `AppPreferenceJournalEvent::UPDATE_PREFERENCE_REGION`
- [ ] `AppPreferenceJournalEvent::UPDATE_PREFERENCE_COLORTHEME`
- [ ] `ComPreferenceJournalEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `ComPreferenceJournalEvent::REFRESH_TOKEN_ROTATED`
- [ ] `ComPreferenceJournalEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `ComPreferenceJournalEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `ComPreferenceJournalEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `ComPreferenceJournalEvent::RESET_BY_USER_DECISION`
- [ ] `ComPreferenceJournalEvent::UPDATE_PREFERENCE_REGION`
- [ ] `ComPreferenceJournalEvent::UPDATE_PREFERENCE_COLORTHEME`
- [ ] `OrgPreferenceJournalEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `OrgPreferenceJournalEvent::REFRESH_TOKEN_ROTATED`
- [ ] `OrgPreferenceJournalEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `OrgPreferenceJournalEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `OrgPreferenceJournalEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `OrgPreferenceJournalEvent::RESET_BY_USER_DECISION`
- [ ] `OrgPreferenceJournalEvent::UPDATE_PREFERENCE_REGION`
- [ ] `OrgPreferenceJournalEvent::UPDATE_PREFERENCE_COLORTHEME`

## Journal Only: Global Notification Root

- [x] `NotificationJournalEvent::DEVICE_REGISTERED`
- [x] `NotificationJournalEvent::DEVICE_REVOKED`
- [x] `NotificationJournalEvent::DEVICE_ROTATED`
- [x] `NotificationJournalEvent::WEBPUSH_SUBSCRIPTION_CREATED`
- [x] `NotificationJournalEvent::WEBPUSH_SUBSCRIPTION_REVOKED`
- [x] `NotificationJournalEvent::IOS_DEVICE_REGISTERED`
- [x] `NotificationJournalEvent::IOS_DEVICE_REVOKED`
- [x] `NotificationJournalEvent::DELIVERY_TARGET_DISABLED`
- [x] `NotificationJournalEvent::DELIVERY_TARGET_ENABLED`
- [x] `NotificationJournalEvent::TOKEN_INVALIDATED`

## Chronicle Only: Regional Content Records

- [x] `AppDocumentChronicleEvent::CREATED`
- [x] `ComDocumentChronicleEvent::CREATED`
- [x] `OrgDocumentChronicleEvent::CREATED`
- [x] `AppDocumentChronicleEvent::UPDATED`
- [x] `ComDocumentChronicleEvent::UPDATED`
- [x] `OrgDocumentChronicleEvent::UPDATED`
- [x] `AppDocumentChronicleEvent::DELETED`
- [x] `ComDocumentChronicleEvent::DELETED`
- [x] `OrgDocumentChronicleEvent::DELETED`
- [x] `AppTimelineChronicleEvent::CREATED`
- [x] `ComTimelineChronicleEvent::CREATED`
- [x] `OrgTimelineChronicleEvent::CREATED`
- [x] `AppTimelineChronicleEvent::UPDATED`
- [x] `ComTimelineChronicleEvent::UPDATED`
- [x] `OrgTimelineChronicleEvent::UPDATED`
- [x] `AppTimelineChronicleEvent::DELETED`
- [x] `ComTimelineChronicleEvent::DELETED`
- [x] `OrgTimelineChronicleEvent::DELETED`

## Chronicle Only: Regional Publishing And Support — EXPLICITLY DEFERRED

These event families require news/docs/help database infrastructure that does not exist yet. They
are deferred until the respective surface has a concrete publication storage model.

- [ ] `NewsChronicleEvent::POST_CREATED` (deferred: no DB infrastructure)
- [ ] `NewsChronicleEvent::POST_UPDATED` (deferred: no DB infrastructure)
- [ ] `NewsChronicleEvent::POST_PUBLISHED` (deferred: no DB infrastructure)
- [ ] `NewsChronicleEvent::POST_UNPUBLISHED` (deferred: no DB infrastructure)
- [ ] `NewsChronicleEvent::VERSION_CREATED` (deferred: no DB infrastructure)
- [ ] `DocsChronicleEvent::POST_CREATED` (deferred: no DB infrastructure)
- [ ] `DocsChronicleEvent::POST_UPDATED` (deferred: no DB infrastructure)
- [ ] `DocsChronicleEvent::POST_PUBLISHED` (deferred: no DB infrastructure)
- [ ] `DocsChronicleEvent::VERSION_CREATED` (deferred: no DB infrastructure)
- [ ] `HelpChronicleEvent::ARTICLE_CREATED` (deferred: no DB infrastructure)
- [ ] `HelpChronicleEvent::ARTICLE_UPDATED` (deferred: no DB infrastructure)
- [ ] `HelpChronicleEvent::ARTICLE_PUBLISHED` (deferred: no DB infrastructure)

## Chronicle Only: Regional Messaging, Search, Billing, And Contact

- [x] `MessageChronicleEvent::SENT`
- [x] `MessageChronicleEvent::UPDATED`
- [x] `MessageChronicleEvent::DELETED`
- [x] `MessageChronicleEvent::DELIVERED`
- [x] `MessageChronicleEvent::DELIVERY_FAILED`
- [x] `MessageChronicleEvent::MODERATION_APPLIED`
- [x] `SearchChronicleEvent::QUERY_EXECUTED`
- [x] `SearchChronicleEvent::INDEX_UPDATED`
- [x] `SearchChronicleEvent::INDEX_REBUILT`
- [x] `BillingChronicleEvent::CHARGE_CREATED`
- [x] `BillingChronicleEvent::CHARGE_CAPTURED`
- [x] `BillingChronicleEvent::CHARGE_FAILED`
- [x] `BillingChronicleEvent::REFUND_CREATED`
- [x] `BillingChronicleEvent::TAX_CALCULATED`
- [x] `ContactChronicleEvent::SUBMITTED`
- [x] `ContactChronicleEvent::UPDATED`
- [x] `ContactChronicleEvent::VERIFICATION_STARTED`
- [x] `ContactChronicleEvent::VERIFICATION_COMPLETED`

## Chronicle Only: Regional Detail And Operations — EXPLICITLY DEFERRED

These event families require news/docs/help/content database infrastructure that does not exist yet.

- [ ] `ContentChronicleEvent::READ` (deferred: no DB infrastructure)
- [ ] `ContentChronicleEvent::VIEWED` (deferred: no DB infrastructure)
- [ ] `ContentChronicleEvent::SHARED` (deferred: no DB infrastructure)
- [ ] `ContentChronicleEvent::FLAGGED` (deferred: no DB infrastructure)
- [ ] `ContentChronicleEvent::MODERATION_REVIEW_STARTED` (deferred: no DB infrastructure)
- [ ] `ContentChronicleEvent::MODERATION_REVIEW_COMPLETED` (deferred: no DB infrastructure)
- [ ] `HelpChronicleEvent::SEARCH_EXECUTED` (deferred: no DB infrastructure)
- [ ] `HelpChronicleEvent::CONTACT_STATUS_CHANGED` (deferred: no DB infrastructure)
- [ ] `DocsChronicleEvent::TAXONOMY_UPDATED` (deferred: no DB infrastructure)
- [ ] `NewsChronicleEvent::TAXONOMY_UPDATED` (deferred: no DB infrastructure)

## Both: Journal Summary Plus Regional Chronicle — FUTURE WORK

Dual-write patterns between journal and chronicle databases require service-layer orchestration that
is out of scope for the current model-layer implementation phase.

- [ ] regulated communication writes a global summary event plus a regional detail event
- [ ] paid-state transition writes a global summary event plus a regional billing detail event
- [ ] moderation that changes account state writes a global summary event plus a regional case event
- [ ] preference changes with regional effect can be projected without duplicating the root event
- [ ] cross-boundary write order is defined for `journal` then `chronicle`
- [ ] cross-boundary write order is defined for `chronicle` then `journal`
- [ ] duplicate detection rules exist for retry-safe dual writes
- [ ] correlation IDs exist for paired `journal` and `chronicle` records
- [ ] tests prove the paired-write happy path
- [ ] tests prove the paired-write partial-failure path

## Model-Layer Test Checklist

- [ ] each `activity only` family has reference-model tests
- [ ] each `journal only` family has reference-model tests
- [ ] each `chronicle only` family has reference-model tests
- [ ] representative record models prove valid event persistence
- [ ] representative record models prove invalid event rejection
- [ ] service tests prove auth-related activity writes
- [ ] service tests prove preference journal writes
- [ ] service tests prove regional chronicle writes
- [ ] tests distinguish activity, journal, and chronicle destination DBs
- [ ] tests do not depend on controller request setup for model-layer event creation
- [ ] tests name the protected rule, not the implementation detail

## Acceptance Criteria

- [ ] the checklist has an explicit owner for each event family before implementation starts
- [ ] model-layer implementation does not expand into controller work in this phase
- [ ] event families that already exist are reconciled against this checklist
- [ ] missing event families are tracked as explicit follow-up items, not hidden gaps
- [ ] implementation reporting can say which boxes are complete and which remain open

## Related

- `plans/analysis/audit-and-evidence-plan.md`
- `plans/analysis/redesign-direction.md`
