# OIDC AuthN Hardening - 判断記録

## What: 何を行うか

OIDC 認証のハードニングと OIDC クレームの整合、`Current.actor`
の fail-fast 化、および受入テストの追加。

## Why: なぜそれを行うか

- `Current.actor` が任意の値を許容しており、セキュリティ上問題がある
- OIDC クレーム契約（`subject_type`, `acr`, `amr`）が設計決定されているのに実装されていない
- 攻撃者志向のテストカバレッジが不足している

## Who: 誰が関係するか

- 実装: AI agent（本セッション）
- 影響モデル: `User`, `Staff`, `Customer`, `Unauthenticated`
- 影響サーフェス: `sign.*`, `core`, `apex`, `docs` の全 relying-party

## When: いつ行うか

- 本番デプロイ時に既存トークンは即座に無効化（required_claims 追加による破壊的変更）
- 既存トークンは短寿命のため自然失収を想定

## Where: どこに変更するか

| 変更対象                     | ファイル                                                  |
| ---------------------------- | --------------------------------------------------------- |
| Current guard logic          | `app/models/current.rb`                                   |
| AuthorizationCode カラム追加 | `db/migrate/*_add_auth_context_to_authorization_codes.rb` |
| TokenClaims                  | `app/services/auth/token_claims.rb`                       |
| TokenService                 | `app/services/auth/token_service.rb`                      |
| TokenExchangeService         | `app/services/oidc/token_exchange_service.rb`             |
| AuthorizeService             | `app/services/oidc/authorize_service.rb`                  |
| Authentication::Base         | `app/controllers/concerns/authentication/base.rb`         |
| Oidc::Callback               | `app/controllers/concerns/oidc/callback.rb`               |
| テスト                       | 各対応テストファイル                                      |

## How: どうやって実装するか

### Phase 1: Current fail-fast 化

- `Current.actor=` に guard: `User`, `Staff`, `Customer` のインスタンス、または
  `Unauthenticated.instance` のみ許可
- `Current.actor_type=` に guard: `:user`, `:staff`, `:customer`, `:unauthenticated` のみ許可
- 不正値は即座に `raise ArgumentError`（TODO: 専用例外クラスに置換予定）

### Phase 2: OIDC claim 追加

- AuthorizationCode に `auth_method`, `acr` カラム追加
- `Auth::TokenClaims.build` に `subject_type`, `acr`, `amr` パラメータ追加
- `Auth::TokenService.encode` に `acr`, `amr` パラメータ追加
- `VALID_ACTOR_TYPES` に `"customer"` 追加
- `TokenService.decode` の `required_claims` に `subject_type`, `acr`, `amr` 追加
- `Oidc::TokenExchangeService` で CustomerToken サポート + id_token 検証 + nonce 検証
- `Oidc::AuthorizeService` で auth_method, acr を AuthorizationCode に保存

### Phase 3: 全トークン発行パスの acr/amr 対応

- `log_in`: auth_method -> amr 正規化して渡す（email -> ["email_otp"], passkey -> ["passkey"] など）
- `build_refreshed_session`: `acr="aal1"` を渡す（リフレッシュ時はダウングレード）
- `reissue_access_token!`: 既存 acr/amr を維持
- `Oidc::TokenExchangeService`: AuthorizationCode から auth_context を取得して acr/amr を設定

### amr 正規化ルール

| auth_method           | amr                 |
| --------------------- | ------------------- |
| `"email"`             | `["email_otp"]`     |
| `"passkey"`           | `["passkey"]`       |
| `"social"` + Google   | `["google"]`        |
| `"social"` + Apple    | `["apple"]`         |
| `"secret"` (recovery) | `["recovery_code"]` |

Step-up 時は検証メソッドを追加: `["email_otp", "totp"]`, `["google", "passkey"]`

## 判断ポイントと根拠

### 1. required_claims の破壊的変更

- **判断**: 既存トークンは即座に無効化
- **根拠**: 既存トークンは短寿命（数分）のため、デプロイ後に自然失収する

### 2. amr の導出方法

- **判断**: 呼び出し元で正規化して渡す
- **根拠**: TokenClaims.build は純粋なビルダーであり、認証方法の推論を行うべきではない

### 3. auth_context の永続化

- **判断**: AuthorizationCode に auth_method, acr カラムを追加
- **根拠**: OIDC code exchange 時に認証コンテキストを確実に引き継ぐため

### 4. nonce 検証の配置

- **判断**: TokenExchangeService で検証
- **根拠**: id_token の署名検証と nonce 検証はトークン交換の一部として完結させる

### 5. Customer のサポート

- **判断**: VALID_ACTOR_TYPES に customer を追加
- **根拠**: 仕様書で Customer が許可された actor として明記されている
