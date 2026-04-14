# Fix inline `default:` strings in `t()` / `I18n.t()` calls

## Background

AGENTS.md now prohibits passing literal strings to the `default:` option of `t()` / `I18n.t()`. All
translation text must be defined in YAML locale files under `config/locales/`.

See the **i18n translation rules** section in AGENTS.md Key Patterns for the full rule.

## Violations to fix

### 1. `app/controllers/sign/com/configuration/totps_controller.rb:41`

```ruby
alert: t("sign.app.verification.unavailable", default: "この認証手段は利用できません。"),
```

**Fix**: Remove `default:` and add the key `sign.app.verification.unavailable` to
`config/locales/ja.yml` and `config/locales/en.yml`.

### 2. `app/controllers/sign/com/in/challenge/totps_controller.rb:23`

```ruby
alert: I18n.t("sign.app.verification.unavailable", default: "この認証手段は利用できません。"),
```

**Fix**: Same key as item 1. After the YAML entry exists, remove `default:`.

### 3. `app/views/sign/com/preferences/show.html.erb:22`

```ruby
t("apex.com.preferences.email_settings", default: "Email settings")
```

**Fix**: Remove `default:` and add the key `apex.com.preferences.email_settings` to both locale
files.

### 4. `app/controllers/concerns/sign/verification_reauth_lifecycle.rb:30`

```ruby
flash[:notice] = I18n.t(verification_success_notice_key, default: "Verification successful")
```

**Fix**: Remove `default:` and add the key referenced by `verification_success_notice_key` to both
locale files. Trace the method to identify the actual key string.

### 5. `app/errors/application_error.rb:16`

```ruby
I18n.t(i18n_key, **context, default: i18n_key)
```

**Fix**: `default:` receives `i18n_key` which is a String (the key path itself), not a Symbol.
Convert to `default: i18n_key.to_sym` if fallback to another key is intended, or remove `default:`
and ensure the key exists in locale files.

## Not a violation

- `app/controllers/sign/com/application_controller.rb:135` — uses `default: nil` with explicit nil
  handling. No change needed.

## Validation

After all fixes, run:

```bash
bundle exec rails test
bundle exec rubocop
```

Confirm that `config.i18n.raise_on_missing_translations = true` (production) does not raise for any
of the affected keys.

## Improvement Points (2026-04-07 Review)

- The repository still contains multiple literal string defaults in controllers and views. Refresh
  the violation inventory before implementation so the fix covers the current code, not only the
  original five examples.
- Add a focused regression test for prohibited runtime string defaults after cleanup. That keeps the
  AGENTS rule enforceable without relying only on manual search.
