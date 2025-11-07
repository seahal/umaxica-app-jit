# Improvement Opportunities

1. Several service objects are empty (`TokenService`, `MessageService`, `NotificationService`, `AccountService`). Either implement the required domain logic or remove the placeholders to avoid runtime surprises.
2. `CoreService` currently returns its own file path and is unused; repurpose it for actual domain logic or delete the stub.
3. `EventPublisher` publishes to topics such as `user_events`, but Karafka routing only defines `email`. Align the topic names with Karafka routes or add the missing routes so messages are delivered.
4. Add unit/integration tests for `EventPublisher` to verify payload shape, headers, and error handling when Kafka is unavailable.
5. Move `ENV["RAILS_ENV"] ||= "test"` before the SimpleCov block so coverage reliably starts in the test environment.
6. Replace the placeholder Bun test with real expectations that exercise JavaScript helpers or view logic.
7. Update the passkey flow to pass the server-provided WebAuthn options into `navigator.credentials.create` instead of using hardcoded defaults.
8. Add capability detection and fallback messaging for browsers without WebAuthn support to improve the passkey UX.
9. Wrap the Base64 decode in `ValidEmailAddressesController` with validation and exception handling; return a 400-style error when decoding fails.
10. In `ValidTelephoneNumbersController`, validate presence/format and return a 422 response with error reasons instead of a bare boolean.
11. Include error codes or messages in the inquiry API responses so clients can display meaningful feedback to users.
12. Guard the Active Record encryption configuration against missing credentials by using `dig` and sensible fallbacks to prevent boot failures.
13. Replace the global `$stderr` override in `config/application.rb` with a library-specific workaround to avoid hiding unrelated warnings.
14. Change the `core` service command in `docker-compose` to boot Rails (or Foreman) instead of `sleep infinity`, enabling immediate dev usage.
15. Replace the hardcoded `trust` auth and static passwords in the Postgres services with environment-driven credentials, even for local development.
16. Provide development defaults or onboarding docs for the `API_*_URL` variables so the scoped routes are available out of the box.
17. Split the single JavaScript bundle per site segment so that each layout loads only the scripts it needs instead of importing every view module.
18. Stop scanning for `app/javascript/controllers` if it does not exist, or create the directory; this avoids unnecessary file system traversal.
19. Swap the `rubocop -A` pre-commit hook for a safer variant (e.g., `--safe-auto-correct`) to reduce unintended edits from unsafe cops.
20. Enable the Karafka process in `Procfile.dev` or document how to start it during development to ensure event-driven features are exercised locally.
