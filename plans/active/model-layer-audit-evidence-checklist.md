# Model-Layer Audit And Evidence Checklist

## Summary

This checklist tracks model-layer implementation readiness for audit and evidence work.

It follows the current working boundary draft:

- `activity` is the global canonical evidence layer
- `behavior` is the regional detailed behavior layer
- controller-level write points are out of scope for this phase

This file is intended for near-term implementation tracking. It is not the full design note. The
design note remains in `plans/analysis/audit-and-evidence-plan.md`.

## Scope

In scope for this checklist:

- event reference models
- event IDs and reference data
- activity and behavior record models
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

- the event has a stable home in `activity`, `behavior`, or both
- the event ID exists as a model constant or documented fixed ID target
- reference data seeding or migration work is defined
- the write path is implemented in the model layer or model-adjacent service layer
- tests prove the expected persistence behavior

## Event Name Normalization Rule

Use model-style event names in this checklist.

- For existing event families, use the current constant form:
  - `UserActivityEvent::LOGGED_IN`
  - `StaffActivityEvent::TOKEN_REFRESHED`
  - `AppTimelineBehaviorEvent::UPDATED`
- For planned event families that do not exist yet, use the intended future model-style form:
  - `MessageBehaviorEvent::SENT`
  - `BillingBehaviorEvent::CHARGE_CREATED`
  - `NotificationActivityEvent::DEVICE_REGISTERED`

This keeps the checklist aligned with model-layer implementation instead of free-form dotted names.

## Foundation And Invariants

- [ ] `activity` is documented as the global canonical evidence layer
- [ ] `behavior` is documented as the regional detailed behavior layer
- [ ] model-layer code does not use subdomain labels as the primary evidence ownership key
- [ ] model-layer code uses explicit event families instead of free-form event names
- [ ] activity event IDs are stable and fixed by constant or seeded reference row
- [ ] behavior event IDs are stable and fixed by constant or seeded reference row
- [ ] each event family has a clear owning record base class
- [ ] event writes do not depend on controller-only context in this phase
- [ ] each write path has a clear failure policy
- [ ] each write path has a clear database destination
- [ ] cross-boundary events can be correlated later without renaming core event IDs
- [ ] acceptance rules distinguish `activity only`, `behavior only`, and `both`

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

## Activity Only: Global Preference Root

- [ ] `AppPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `AppPreferenceActivityEvent::REFRESH_TOKEN_ROTATED`
- [ ] `AppPreferenceActivityEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `AppPreferenceActivityEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `AppPreferenceActivityEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `AppPreferenceActivityEvent::RESET_BY_USER_DECISION`
- [ ] `AppPreferenceActivityEvent::UPDATE_PREFERENCE_REGION`
- [ ] `AppPreferenceActivityEvent::UPDATE_PREFERENCE_COLORTHEME`
- [ ] `ComPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `ComPreferenceActivityEvent::REFRESH_TOKEN_ROTATED`
- [ ] `ComPreferenceActivityEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `ComPreferenceActivityEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `ComPreferenceActivityEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `ComPreferenceActivityEvent::RESET_BY_USER_DECISION`
- [ ] `ComPreferenceActivityEvent::UPDATE_PREFERENCE_REGION`
- [ ] `ComPreferenceActivityEvent::UPDATE_PREFERENCE_COLORTHEME`
- [ ] `OrgPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN`
- [ ] `OrgPreferenceActivityEvent::REFRESH_TOKEN_ROTATED`
- [ ] `OrgPreferenceActivityEvent::UPDATE_PREFERENCE_COOKIE`
- [ ] `OrgPreferenceActivityEvent::UPDATE_PREFERENCE_LANGUAGE`
- [ ] `OrgPreferenceActivityEvent::UPDATE_PREFERENCE_TIMEZONE`
- [ ] `OrgPreferenceActivityEvent::RESET_BY_USER_DECISION`
- [ ] `OrgPreferenceActivityEvent::UPDATE_PREFERENCE_REGION`
- [ ] `OrgPreferenceActivityEvent::UPDATE_PREFERENCE_COLORTHEME`

## Activity Only: Global Notification Root

- [x] `NotificationActivityEvent::DEVICE_REGISTERED`
- [x] `NotificationActivityEvent::DEVICE_REVOKED`
- [x] `NotificationActivityEvent::DEVICE_ROTATED`
- [x] `NotificationActivityEvent::WEBPUSH_SUBSCRIPTION_CREATED`
- [x] `NotificationActivityEvent::WEBPUSH_SUBSCRIPTION_REVOKED`
- [x] `NotificationActivityEvent::IOS_DEVICE_REGISTERED`
- [x] `NotificationActivityEvent::IOS_DEVICE_REVOKED`
- [x] `NotificationActivityEvent::DELIVERY_TARGET_DISABLED`
- [x] `NotificationActivityEvent::DELIVERY_TARGET_ENABLED`
- [x] `NotificationActivityEvent::TOKEN_INVALIDATED`

## Behavior Only: Regional Content Records

- [x] `AppDocumentBehaviorEvent::CREATED`
- [x] `ComDocumentBehaviorEvent::CREATED`
- [x] `OrgDocumentBehaviorEvent::CREATED`
- [x] `AppDocumentBehaviorEvent::UPDATED`
- [x] `ComDocumentBehaviorEvent::UPDATED`
- [x] `OrgDocumentBehaviorEvent::UPDATED`
- [x] `AppDocumentBehaviorEvent::DELETED`
- [x] `ComDocumentBehaviorEvent::DELETED`
- [x] `OrgDocumentBehaviorEvent::DELETED`
- [x] `AppTimelineBehaviorEvent::CREATED`
- [x] `ComTimelineBehaviorEvent::CREATED`
- [x] `OrgTimelineBehaviorEvent::CREATED`
- [x] `AppTimelineBehaviorEvent::UPDATED`
- [x] `ComTimelineBehaviorEvent::UPDATED`
- [x] `OrgTimelineBehaviorEvent::UPDATED`
- [x] `AppTimelineBehaviorEvent::DELETED`
- [x] `ComTimelineBehaviorEvent::DELETED`
- [x] `OrgTimelineBehaviorEvent::DELETED`

## Behavior Only: Regional Publishing And Support — EXPLICITLY DEFERRED

These event families require news/docs/help database infrastructure that does not exist yet. They
are deferred until the respective surface has a concrete publication storage model.

- [ ] `NewsBehaviorEvent::POST_CREATED` (deferred: no DB infrastructure)
- [ ] `NewsBehaviorEvent::POST_UPDATED` (deferred: no DB infrastructure)
- [ ] `NewsBehaviorEvent::POST_PUBLISHED` (deferred: no DB infrastructure)
- [ ] `NewsBehaviorEvent::POST_UNPUBLISHED` (deferred: no DB infrastructure)
- [ ] `NewsBehaviorEvent::VERSION_CREATED` (deferred: no DB infrastructure)
- [ ] `DocsBehaviorEvent::POST_CREATED` (deferred: no DB infrastructure)
- [ ] `DocsBehaviorEvent::POST_UPDATED` (deferred: no DB infrastructure)
- [ ] `DocsBehaviorEvent::POST_PUBLISHED` (deferred: no DB infrastructure)
- [ ] `DocsBehaviorEvent::VERSION_CREATED` (deferred: no DB infrastructure)
- [ ] `HelpBehaviorEvent::ARTICLE_CREATED` (deferred: no DB infrastructure)
- [ ] `HelpBehaviorEvent::ARTICLE_UPDATED` (deferred: no DB infrastructure)
- [ ] `HelpBehaviorEvent::ARTICLE_PUBLISHED` (deferred: no DB infrastructure)

## Behavior Only: Regional Messaging, Search, Billing, And Contact

- [x] `MessageBehaviorEvent::SENT`
- [x] `MessageBehaviorEvent::UPDATED`
- [x] `MessageBehaviorEvent::DELETED`
- [x] `MessageBehaviorEvent::DELIVERED`
- [x] `MessageBehaviorEvent::DELIVERY_FAILED`
- [x] `MessageBehaviorEvent::MODERATION_APPLIED`
- [x] `SearchBehaviorEvent::QUERY_EXECUTED`
- [x] `SearchBehaviorEvent::INDEX_UPDATED`
- [x] `SearchBehaviorEvent::INDEX_REBUILT`
- [x] `BillingBehaviorEvent::CHARGE_CREATED`
- [x] `BillingBehaviorEvent::CHARGE_CAPTURED`
- [x] `BillingBehaviorEvent::CHARGE_FAILED`
- [x] `BillingBehaviorEvent::REFUND_CREATED`
- [x] `BillingBehaviorEvent::TAX_CALCULATED`
- [x] `ContactBehaviorEvent::SUBMITTED`
- [x] `ContactBehaviorEvent::UPDATED`
- [x] `ContactBehaviorEvent::VERIFICATION_STARTED`
- [x] `ContactBehaviorEvent::VERIFICATION_COMPLETED`

## Behavior Only: Regional Detail And Operations — EXPLICITLY DEFERRED

These event families require news/docs/help/content database infrastructure that does not exist yet.

- [ ] `ContentBehaviorEvent::READ` (deferred: no DB infrastructure)
- [ ] `ContentBehaviorEvent::VIEWED` (deferred: no DB infrastructure)
- [ ] `ContentBehaviorEvent::SHARED` (deferred: no DB infrastructure)
- [ ] `ContentBehaviorEvent::FLAGGED` (deferred: no DB infrastructure)
- [ ] `ContentBehaviorEvent::MODERATION_REVIEW_STARTED` (deferred: no DB infrastructure)
- [ ] `ContentBehaviorEvent::MODERATION_REVIEW_COMPLETED` (deferred: no DB infrastructure)
- [ ] `HelpBehaviorEvent::SEARCH_EXECUTED` (deferred: no DB infrastructure)
- [ ] `HelpBehaviorEvent::CONTACT_STATUS_CHANGED` (deferred: no DB infrastructure)
- [ ] `DocsBehaviorEvent::TAXONOMY_UPDATED` (deferred: no DB infrastructure)
- [ ] `NewsBehaviorEvent::TAXONOMY_UPDATED` (deferred: no DB infrastructure)

## Both: Global Summary Plus Regional Detail — FUTURE WORK

Dual-write patterns between activity and behavior databases require service-layer orchestration that
is out of scope for the current model-layer implementation phase.

- [ ] regulated communication writes a global summary event plus a regional detail event
- [ ] paid-state transition writes a global summary event plus a regional billing detail event
- [ ] moderation that changes account state writes a global summary event plus a regional case event
- [ ] preference changes with regional effect can be projected without duplicating the root event
- [ ] cross-boundary write order is defined for `activity` then `behavior`
- [ ] cross-boundary write order is defined for `behavior` then `activity`
- [ ] duplicate detection rules exist for retry-safe dual writes
- [ ] correlation IDs exist for paired `activity` and `behavior` records
- [ ] tests prove the paired-write happy path
- [ ] tests prove the paired-write partial-failure path

## Model-Layer Test Checklist

- [ ] each `activity only` family has reference-model tests
- [ ] each `behavior only` family has reference-model tests
- [ ] representative record models prove valid event persistence
- [ ] representative record models prove invalid event rejection
- [ ] service tests prove auth-related activity writes
- [ ] service tests prove preference activity writes
- [ ] service tests prove regional behavior writes
- [ ] tests distinguish global versus regional destination DBs
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
