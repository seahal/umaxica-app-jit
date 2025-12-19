# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Rails 8.0 application with a sophisticated multi-domain, multi-database architecture:

### Domain Structure
アプリケーションは複数のエンドポイントで構成され、各エンドポイントが3つのドメイン(com/app/org)を持ちます:

- **APEX** (旧TOP): トップページとプリファレンス管理
  - `APEX_CORPORATE_URL` (com): コーポレートサイトトップ
  - `APEX_SERVICE_URL` (app): サービスアプリトップ
  - `APEX_STAFF_URL` (org): スタッフ管理画面トップ

- **SIGN**: 認証・登録・ログイン・退会
  - `SIGN_SERVICE_URL` (app): ユーザー認証ページ（完全実装済み）
  - `SIGN_STAFF_URL` (org): スタッフ認証ページ（基本機能のみ、認証フロー未実装）
  - WebAuthn, TOTP, Apple/Google OAuth対応

- **BACK** (旧BFF): Backend for Frontend
  - `BACK_CORPORATE_URL` (com): クライアント向けBFF
  - `BACK_SERVICE_URL` (app): サービス向けBFF
  - `BACK_STAFF_URL` (org): スタッフ向けBFF

- **HELP**: ヘルプ・問い合わせページ
  - `HELP_CORPORATE_URL`, `HELP_SERVICE_URL`, `HELP_STAFF_URL`

- **DOCS**: ドキュメントページ
  - `DOCS_CORPORATE_URL`, `DOCS_SERVICE_URL`, `DOCS_STAFF_URL`

- **NEWS**: ニュースページ
  - `NEWS_CORPORATE_URL`, `NEWS_SERVICE_URL`, `NEWS_STAFF_URL`

### Multi-Database Setup
The application uses 10 separate PostgreSQL databases with primary/replica configurations:

**マイグレーション管理されているDB** (migration paths: `db/{database_name}_migrate/`):
- `universal` (universals_migrate) - Universal identifiers and user data
- `identity` (identities_migrate) - Authentication and identity management
- `guest` (guests_migrate) - Guest contact information and communication
- `profile` (profiles_migrate) - User profiles and preferences
- `token` (tokens_migrate) - Session and authentication tokens
- `business` (businesses_migrate) - Business logic and entities
- `speciality` (specialities_migrate) - Domain-specific features
- `primary` (migrate) - Primary database

**スキーマのみ管理されているDB** (schema files exist, no migration directory):
- `notification` (notification_schema.rb) - Notification management
- `cache` (cache_schema.rb) - Application caching (Solid Cache)
- `queue` (queue_schema.rb) - Background job queue (Solid Queue)
- `storage` (storage_schema.rb) - File storage metadata

**注意**:
- 各データベースは`config/database.yml`でプライマリ/レプリカペアとして構成されています
- データベース接続名: `{db_name}` (primary), `{db_name}_replica` (replica)
- ドキュメントに記載されていた`message`データベースは実際には存在しません

### Controller Organization
Controllers are organized by endpoint module and domain:
- `app/controllers/apex/{com,app,org}/` - トップページコントローラー
- `app/controllers/sign/{app,org}/` - 認証・登録コントローラー
- `app/controllers/back/{com,app,org}/` - BFFコントローラー
- `app/controllers/help/{com,app,org}/` - ヘルプ・問い合わせコントローラー
- `app/controllers/docs/{com,app,org}/` - ドキュメントコントローラー
- `app/controllers/news/{com,app,org}/` - ニュースコントローラー
- `app/controllers/concerns/` - 共通コントローラーロジック
- `app/controllers/{endpoint}/concerns/` - エンドポイント固有のConcerns

### Key Technologies
- **Authentication**: WebAuthn, TOTP, Apple/Google OAuth, recovery codes
- **Authorization**: Pundit
- **Background Jobs**: Solid Queue (DB-based queue), Karafka (Kafka-based, currently disabled)
- **Frontend**: Rails with Bun.js for asset bundling
- **File Uploads**: Shrine + Active Storage with Google Cloud Storage
- **Security**: Rack::Attack for rate limiting, argon2 for password hashing
- **Monitoring**: OpenTelemetry instrumentation
- **Logging**: Structured logging with Rails.event (ActiveSupport::Notifications)

## Development Commands

### Setup and Dependencies
```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies (requires Bun)
bun install

# Database setup (requires Docker Compose)
docker compose up -d  # Start PostgreSQL containers
bundle exec rails db:create
bundle exec rails db:migrate
```

### Development Server
```bash
# Start all services (web server, asset building)
foreman start -f Procfile.dev

# Or individually:
bundle exec rails server -p 3000 -b '0.0.0.0'
bun run build --watch
# bundle exec karafka server  # 現在は無効化されています
```

### Testing
```bash
# Run all tests
bundle exec rails test

# Run specific test file
bundle exec rails test test/models/user_test.rb

# Run tests for specific controller
bundle exec rails test test/controllers/sign/app/authentications_controller_test.rb

# Continuous testing with Guard
bundle exec guard
```

### Code Quality
```bash
# Ruby linting
bundle exec rubocop
bundle exec rubocop --fix

# ERB template linting
bundle exec erb_lint app/views/

# JavaScript/TypeScript linting and formatting
bun run lint
bun run format
bun run type

# Security scanning
bundle exec brakeman
bundle exec bundler-audit
```

### Database Operations
```bash
# Create migration for specific database (use the database key name from database.yml)
bundle exec rails generate migration CreateUsers --database=identity

# Run migrations for specific database
bundle exec rails db:migrate:identity

# Run all database migrations
bundle exec rails db:migrate

# Reset all databases
bundle exec rails db:drop db:create db:migrate

# 注意: データベース名は database.yml のキー名を使用
# 例: identity, universal, guest, profile, token, business, speciality
```

## Structured Logging

このアプリケーションは構造化ログを使用しています。従来の`Rails.logger.info`ではなく、`Rails.event`（ActiveSupport::Notifications）を使用してログを出力します。

### 構造化ログの利点
- **解析可能**: ログがJSON形式で構造化され、ログ集約ツールで簡単に検索・分析可能
- **コンテキスト情報**: リクエストID、ユーザーID、セッション情報などを自動的に含む
- **一貫性**: すべてのログが同じフォーマットに従う
- **OpenTelemetry統合**: トレーシングとログが自動的に関連付けられる

### Rails.eventの使い方

#### 基本的な使用方法
```ruby
# イベントの発行
Rails.event.notify("user.login", user_id: user.id, ip_address: request.remote_ip)

# エラーイベント（errorメソッドは存在しないため、notifyを使用）
Rails.event.notify("authentication.failed",
  error_class: error.class.name,
  error_message: error.message,
  user_id: user&.id
)

# デバッグモードのみでログ出力
Rails.event.debug("api.request",
  endpoint: request.path,
  method: request.method,
  params: filtered_params
)
```

#### イベント名の命名規則
イベント名は `{domain}.{action}` の形式を使用:
- `user.login`, `user.logout` - ユーザー認証関連
- `staff.login`, `staff.logout` - スタッフ認証関連
- `api.request`, `api.response` - APIリクエスト関連
- `database.query` - データベースクエリ関連
- `job.enqueue`, `job.perform` - バックグラウンドジョブ関連
- `security.rate_limit`, `security.suspicious_activity` - セキュリティ関連

#### コントローラーでの使用例
```ruby
class Sign::App::AuthenticationsController < Sign::App::BaseController
  def create
    user = authenticate_user(params)

    if user
      Rails.event.notify("user.login.success",
        user_id: user.id,
        authentication_method: params[:method],
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      redirect_to root_path
    else
      Rails.event.notify("user.login.failed",
        email: params[:email],
        reason: "invalid_credentials",
        ip_address: request.remote_ip
      )
      render :new, status: :unauthorized
    end
  end
end
```

#### モデルでの使用例
```ruby
class User < UniversalRecord
  after_create do
    Rails.event.notify("user.created",
      user_id: id,
      email: email,
      registration_method: registration_method
    )
  end

  def perform_sensitive_action
    Rails.event.notify("user.sensitive_action",
      user_id: id,
      action: "data_export",
      timestamp: Time.current
    )

    # アクション実行
  rescue StandardError => e
    Rails.event.notify("user.action_failed",
      user_id: id,
      action: "data_export",
      error_class: e.class.name,
      error_message: e.message,
      backtrace: e.backtrace.first(5)
    )
    raise
  end
end
```

#### バックグラウンドジョブでの使用例
```ruby
class UserNotificationJob < ApplicationJob
  def perform(user_id, notification_type)
    Rails.event.notify("job.started",
      job_class: self.class.name,
      user_id: user_id,
      notification_type: notification_type
    )

    # ジョブ実行

    Rails.event.notify("job.completed",
      job_class: self.class.name,
      user_id: user_id,
      duration: duration
    )
  end
end
```

### 重要な注意事項
- **機密情報を含めない**: パスワード、トークン、クレジットカード番号などをログに出力しない
- **正しいメソッド**: `Rails.event.notify`を使用（`record`や`error`メソッドは存在しない）
- **デバッグ用**: デバッグモードのみでログ出力する場合は`Rails.event.debug`を使用
- **従来のロガーは使わない**: `Rails.logger.info`の代わりに`Rails.event.notify`を使用
- **パフォーマンス**: 大量のデータをログに出力する場合は注意（必要な情報のみ）

## Key Patterns

### Model Concerns
Shared model logic is in `app/models/concerns/`:
- `Email` - Email validation and normalization
- `Telephone` - Phone number handling
- `SetId` - ID generation patterns
- `RecoverCode` - Recovery code management

### Authentication Flow
- Multi-factor authentication with WebAuthn, TOTP, recovery codes
- Social login via Apple/Google OAuth
- Session management across multiple domains
- Email/telephone verification workflows

### Database Connections
Models inherit from database-specific base classes:
- `UniversalRecord` - Universal database
- `IdentityRecord` - Identity database (認証・識別情報)
- `GuestRecord` - Guest database (ゲスト連絡情報)
- `ProfileRecord` - Profile database (ユーザープロフィール)
- `TokenRecord` - Token database (セッション・認証トークン)
- `BusinessRecord` - Business database (ビジネスロジック)
- `SpecialityRecord` - Speciality database (特殊機能)
- `NotificationRecord` - Notification database (通知管理)
- `CacheRecord` - Cache database (Solid Cache用)
- `QueueRecord` - Queue database (Solid Queue用)
- `StorageRecord` - Storage database (ストレージメタデータ)

### View Components
Uses ViewComponent gem for reusable UI components. Components are in `app/components/`.

### Route Organization
Routes are split by endpoint in `config/routes/`:
- `apex.rb` - トップページルート (com/app/org)
- `sign.rb` - 認証・登録ルート (app/org)
- `back.rb` - BFFルート (com/app/org)
- `help.rb` - ヘルプ・問い合わせルート (com/app/org)
- `docs.rb` - ドキュメントルート (com/app/org)
- `news.rb` - ニュースルート (com/app/org)

各ルートファイルは、ホスト制約(`constraints host:`)で3つのドメイン(com/app/org)に分岐し、
それぞれに対応するコントローラーモジュールにルーティングします。

#### 主要なルート構成

**APEX** (`config/routes/apex.rb`):
- `root` - トップページ (`roots#index`)
- `resource :health` - ヘルスチェック
- `namespace :v1` - API v1エンドポイント
- `resource :preference` - プリファレンス表示
- `resource :privacy` - プライバシー表示
- `namespace :privacy` - Cookie設定
- `namespace :preference` - Region, Locale, Theme, Reset設定
- `resource :configuration` (appのみ) - 設定表示
- `namespace :configuration` - Email設定 (appのみ)

**SIGN** (`config/routes/sign.rb`):
- **app** (完全実装):
  - `root` - サインページトップ
  - `resource :registration` - ユーザー登録
    - `resources :emails` - メールアドレス登録
    - `resources :telephones` - 電話番号登録
    - `resources :googles` - Google OAuth登録
  - `resource :authentication` - 認証・ログイン
    - `resource :email`, `resource :telephone` - メール/電話認証
    - `resource :apple`, `resource :google` - OAuth認証
  - `namespace :oauth` - OAuthコールバック処理
    - `apple/callback`, `google/callback`
  - `resource :withdrawal` - 退会処理
  - `resource :setting` - ログインユーザー設定
    - `resources :passkeys` - WebAuthn設定
    - `resources :totps` - TOTP設定
    - `resources :secrets` - リカバリーコード管理
- **org** (基本機能のみ):
  - `root` - サインページトップ
  - `resource :registration` - スタッフ登録（基本のみ）
    - `resources :emails`, `resources :telephones`
  - `resource :authentication` - 認証（newのみ）
  - `namespace :setting` - 設定
    - `resources :passkeys`, `resources :secrets`
  - `resource :withdrawal` - 退会処理

**BACK** (`config/routes/back.rb`):
- `root` - BFFトップ
- `resource :health` - ヘルスチェック
- `namespace :v1` - API v1
- `resource :preference` - プリファレンス (app/orgのみ)
- `namespace :preference` - Email設定 (app/orgのみ)

**HELP** (`config/routes/help.rb`):
- `root` - ヘルプトップ
- `resource :health` - ヘルスチェック
- `resources :contacts` - 問い合わせ
  - `scope module: :contact`:
    - `resource :email` - メール問い合わせ
    - `resource :telephone` - 電話問い合わせ

**DOCS** / **NEWS** (`config/routes/docs.rb` / `news.rb`):
- `root` - ドキュメント/ニューストップ
- `resource :health` - ヘルスチェック
- `namespace :v1` - API v1

## Environment Variables

Key environment variables required:

### Domain URLs (各エンドポイント × 3ドメイン)
- `APEX_CORPORATE_URL`, `APEX_SERVICE_URL`, `APEX_STAFF_URL`
- `SIGN_SERVICE_URL`, `SIGN_STAFF_URL` (SIGNはcomなし)
- `BACK_CORPORATE_URL`, `BACK_SERVICE_URL`, `BACK_STAFF_URL`
- `HELP_CORPORATE_URL`, `HELP_SERVICE_URL`, `HELP_STAFF_URL`
- `DOCS_CORPORATE_URL`, `DOCS_SERVICE_URL`, `DOCS_STAFF_URL`
- `NEWS_CORPORATE_URL`, `NEWS_SERVICE_URL`, `NEWS_STAFF_URL`

### Database Settings
- `POSTGRESQL_USER`, `POSTGRESQL_PASSWORD` - DB認証情報
- `POSTGRESQL_*_PUB`, `POSTGRESQL_*_SUB` - 各DBのプライマリ/レプリカホスト
  - 例: `POSTGRESQL_UNIVERSAL_PUB`, `POSTGRESQL_UNIVERSAL_SUB`

### Application Settings
- `RAILS_MAX_THREADS` - Threading configuration
- `RACK_ATTACK_API_KEY` - API key for Rack::Attack authentication

## Important Notes

- Always run `bundle install` after pulling changes due to frequent gem updates
- Use domain-specific controllers and routes - check the constraint blocks in routes
- Database migrations must specify the correct database with `--database` flag
- Test files follow the endpoint/domain structure: `test/controllers/{endpoint}/{domain}/{version}/`
  - 例: `test/controllers/apex/app/`, `test/controllers/sign/app/`
- Asset compilation uses Bun - ensure Bun is installed locally
- The application expects Docker Compose for local database setup
- **注意**: 実際のコントローラー構造とルートファイル名は `apex`, `back` を使用（環境変数は従来の命名を維持）

### 禁止事項
- `.env`ファイルの作成・変更
- `node_modules`内のファイル編集
- テストを実行せずにコミット
- 承認なしでのPRマージ
- test/test_helper.rb の操作は駄目です。
- config/ の操作は許可を取ること。

### コーディング規約
- **ログ出力**: 従来の`Rails.logger.info`は使用せず、必ず`Rails.event.notify`を使用する
- **構造化ログ**: すべてのログは構造化されたイベントとして記録する
- **機密情報**: ログに機密情報（パスワード、トークン、APIキーなど）を含めない
- **リフレッシュトークンローテーション**: リフレッシュトークンを使用する際は必ず新しいトークンを発行し、古いトークンを無効化する
