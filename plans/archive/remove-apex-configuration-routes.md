# Remove redundant apex configuration routes

## Context

`apex.rb` の app / org スコープに `TODO: consider this. we did move this to sign routing.`
というコメントがある。configuration ルートと関連コントローラ・ビューが sign 側に完全移行済みにもかかわらず apex 側にスタブとして残っている。com スコープにも同じ構造が TODO なしで残っている。

sign 側は emails, totps, passkeys, secrets, sessions, activities,
withdrawal 等を含む完全版。apex 側は show + emails
(new/create/edit/update) のみのスタブ。レイアウトのヘッダーは既に `sign_*_configuration_url`
にリンクしているが、フッターと roots/index は apex 側を参照している。

apex/com/configuration/emails/edit.html.erb にコピペバグあり（`apex_app_*` を使っていて `apex_com_*`
であるべき）。

## Approach

### Step 1: Route deletion — `config/routes/apex.rb`

以下のブロックを削除:

- **com scope** (L35-39): `resource :configuration` + `namespace :configuration { emails }`
- **app scope** (L71-76): TODO comment + `resource :configuration` +
  `namespace :configuration { emails }`
- **org scope** (L129-134): TODO comment + `resource :configuration` +
  `namespace :configuration { emails }`

### Step 2: Controller deletion

- `app/controllers/apex/app/configurations_controller.rb`
- `app/controllers/apex/com/configurations_controller.rb`
- `app/controllers/apex/org/configurations_controller.rb`
- `app/controllers/apex/app/configuration/emails_controller.rb`
- `app/controllers/apex/org/configuration/emails_controller.rb`

（apex/com/configuration/emails_controller.rb は存在しない）

### Step 3: View deletion

- `app/views/apex/app/configurations/` (show.html.erb)
- `app/views/apex/com/configurations/` (show.html.erb)
- `app/views/apex/org/configurations/` (show.html.erb)
- `app/views/apex/app/configuration/emails/` (edit.html.erb 等)
- `app/views/apex/com/configuration/emails/` (edit.html.erb 等)
- `app/views/apex/org/configuration/emails/` (edit.html.erb 等)

### Step 4: Link re-pointing

apex のレイアウト・ルートページで `apex_*_configuration_path` を使っている箇所を
`sign_*_configuration_url`
に変更する。ヘッダーは既に sign を向いているので、フッターと roots/index のみ:

| File                                                  | Change                                                       |
| ----------------------------------------------------- | ------------------------------------------------------------ |
| `app/views/layouts/apex/app/application.html.erb` L50 | `apex_app_configuration_path` → `sign_app_configuration_url` |
| `app/views/layouts/apex/org/application.html.erb` L50 | `apex_org_configuration_path` → `sign_org_configuration_url` |
| `app/views/apex/app/roots/index.html.erb` L20         | `apex_app_configuration_path` → `sign_app_configuration_url` |
| `app/views/apex/org/roots/index.html.erb` L19         | `apex_org_configuration_path` → `sign_org_configuration_url` |

### Step 5: Test deletion and update

- `test/controllers/apex/com/configurations_controller_test.rb` — delete file
- `test/controllers/apex/coverage_test.rb` — delete configuration test cases (around L15, L24)

### Step 6: Empty directory cleanup

削除後に空になるディレクトリを確認し削除:

- `app/controllers/apex/app/configuration/`
- `app/controllers/apex/com/configuration/` (if exists)
- `app/controllers/apex/org/configuration/`
- `app/views/apex/*/configurations/`
- `app/views/apex/*/configuration/`

## Verification

1. `bundle exec rails routes | grep apex.*configuration` — routes are gone
2. `grep -r "apex.*configuration" app/ test/ config/routes/` — no remaining references
3. `bundle exec rubocop`
4. `bundle exec erb_lint .`
5. `bundle exec rails test test/controllers/apex/` — apex tests pass
