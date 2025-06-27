# FIDO2 セキュリティキー実装タスクリスト

## 現状分析

### 実装済み ✅
- **WebAuthn Gem**: `webauthn` v3.4 導入済み
- **設定ファイル**: `/config/webauthn.rb` で多ドメイン対応設定完了
- **コントローラー構造**: スケルトン実装あり
- **ルーティング**: 全ドメインで設定済み
- **ビューテンプレート**: 基本構造あり

### 未実装 ❌
- **データベースモデル**: WebAuthn認証情報保存用テーブルなし
- **コントローラーロジック**: 登録・認証処理未実装
- **JavaScript実装**: WebAuthn browser API統合なし
- **セキュリティ統合**: 既存MFAシステムとの連携なし

## 実装タスク

### 1. データベース設計・実装 🔴 **HIGH PRIORITY**

#### 1.1 マイグレーション作成
```bash
# identifierデータベースに作成
rails generate migration CreateWebauthnCredentials --database=identifier
rails generate migration CreateStaffWebauthnCredentials --database=identifier
```

#### 1.2 必要なテーブル構造
```ruby
# webauthn_credentials (一般ユーザー用)
# staff_webauthn_credentials (スタッフ用)

# 必要フィールド:
- user_id/staff_id (外部キー)
- external_id (WebAuthn credential ID, Base64URL encoded)
- public_key (公開鍵, binary)
- sign_count (署名カウンター, bigint)
- nickname (ユーザー定義名, string)
- last_used_at (最終使用日時, datetime)
- created_at, updated_at (datetime)
- transports (利用可能transport, json array)
- aaguid (authenticator GUID, binary, optional)
```

#### 1.3 インデックス設計
```sql
-- 高速検索用インデックス
INDEX idx_webauthn_credentials_user_id (user_id)
INDEX idx_webauthn_credentials_external_id (external_id)
INDEX idx_staff_webauthn_credentials_staff_id (staff_id)
INDEX idx_staff_webauthn_credentials_external_id (external_id)
```

### 2. モデル実装 🔴 **HIGH PRIORITY**

#### 2.1 WebAuthnCredential モデル
```ruby
# app/models/webauthn_credential.rb
class WebauthnCredential < IdentifiersRecord
  belongs_to :user
  
  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :nickname, presence: true, length: { maximum: 255 }
  
  scope :recent, -> { order(last_used_at: :desc) }
  
  def update_sign_count!(new_count)
    # Replay attack prevention
    return false if new_count <= sign_count
    update!(sign_count: new_count, last_used_at: Time.current)
    true
  end
end
```

#### 2.2 StaffWebauthnCredential モデル
```ruby
# app/models/staff_webauthn_credential.rb
class StaffWebauthnCredential < IdentifiersRecord
  belongs_to :staff
  
  # WebauthnCredentialと同様の実装
end
```

#### 2.3 User/Staff モデル拡張
```ruby
# app/models/user.rb に追加
has_many :webauthn_credentials, dependent: :destroy

def webauthn_enabled?
  webauthn_credentials.exists?
end

# app/models/staff.rb に追加
has_many :staff_webauthn_credentials, dependent: :destroy

def webauthn_enabled?
  staff_webauthn_credentials.exists?
end
```

### 3. JavaScript WebAuthn API実装 🔴 **HIGH PRIORITY**

#### 3.1 ディレクトリ構造
```
app/javascript/webauthn/
├── registration.js     # 登録フロー
├── authentication.js  # 認証フロー
├── management.js       # 管理機能
└── utils.js           # 共通ユーティリティ
```

#### 3.2 登録フロー JavaScript
```javascript
// app/javascript/webauthn/registration.js
export class WebAuthnRegistration {
  static async register(options) {
    try {
      // navigator.credentials.create() の実装
      const credential = await navigator.credentials.create({
        publicKey: options
      });
      
      return {
        id: credential.id,
        rawId: arrayBufferToBase64Url(credential.rawId),
        response: {
          attestationObject: arrayBufferToBase64Url(credential.response.attestationObject),
          clientDataJSON: arrayBufferToBase64Url(credential.response.clientDataJSON)
        },
        type: credential.type
      };
    } catch (error) {
      throw new WebAuthnError(error.message);
    }
  }
}
```

#### 3.3 認証フロー JavaScript
```javascript
// app/javascript/webauthn/authentication.js
export class WebAuthnAuthentication {
  static async authenticate(options) {
    try {
      // navigator.credentials.get() の実装
      const assertion = await navigator.credentials.get({
        publicKey: options
      });
      
      return {
        id: assertion.id,
        rawId: arrayBufferToBase64Url(assertion.rawId),
        response: {
          authenticatorData: arrayBufferToBase64Url(assertion.response.authenticatorData),
          clientDataJSON: arrayBufferToBase64Url(assertion.response.clientDataJSON),
          signature: arrayBufferToBase64Url(assertion.response.signature),
          userHandle: assertion.response.userHandle ? arrayBufferToBase64Url(assertion.response.userHandle) : null
        },
        type: assertion.type
      };
    } catch (error) {
      throw new WebAuthnError(error.message);
    }
  }
}
```

### 4. コントローラーロジック実装 🔴 **HIGH PRIORITY**

#### 4.1 認証用パスキーコントローラー
```ruby
# app/controllers/www/app/authentication/passkeys_controller.rb
class Www::App::Authentication::PasskeysController < Www::App::ApplicationController
  def new
    # 認証オプション生成
    @options = WebAuthn::Credential.options_for_get(
      allow: user_credentials_for_authentication,
      user_verification: 'preferred'
    )
    session[:webauthn_challenge] = @options.challenge
  end

  def create
    # WebAuthn assertion検証
    webauthn_credential = WebAuthn::Credential.from_get(credential_params)
    
    stored_credential = find_credential(webauthn_credential.id)
    return render_error('認証に失敗しました') unless stored_credential
    
    begin
      webauthn_credential.verify(
        session.delete(:webauthn_challenge),
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count
      )
      
      stored_credential.update_sign_count!(webauthn_credential.sign_count)
      sign_in_user(stored_credential.user)
      redirect_to_after_sign_in
      
    rescue WebAuthn::Error => e
      render_error('認証に失敗しました')
    end
  end
end
```

#### 4.2 設定用パスキーコントローラー
```ruby
# app/controllers/www/app/setting/passkeys_controller.rb
class Www::App::Setting::PasskeysController < Www::App::ApplicationController
  before_action :authenticate_user!
  
  def index
    @credentials = current_user.webauthn_credentials.recent
  end

  def new
    # 登録オプション生成
    @options = WebAuthn::Credential.options_for_create(
      user: webauthn_user_entity,
      exclude: existing_credential_ids
    )
    session[:webauthn_challenge] = @options.challenge
  end

  def create
    # WebAuthn credential検証・保存
    webauthn_credential = WebAuthn::Credential.from_create(credential_params)
    
    begin
      webauthn_credential.verify(session.delete(:webauthn_challenge))
      
      current_user.webauthn_credentials.create!(
        external_id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
        nickname: params[:nickname].presence || "セキュリティキー #{DateTime.current.strftime('%Y/%m/%d')}"
      )
      
      redirect_to setting_passkeys_path, notice: 'セキュリティキーを登録しました'
      
    rescue WebAuthn::Error => e
      render_error('登録に失敗しました')
    end
  end

  def destroy
    credential = current_user.webauthn_credentials.find(params[:id])
    credential.destroy!
    redirect_to setting_passkeys_path, notice: 'セキュリティキーを削除しました'
  end
end
```

### 5. ビュー実装 🟡 **MEDIUM PRIORITY**

#### 5.1 認証画面
```erb
<!-- app/views/www/app/authentication/passkeys/new.html.erb -->
<div class="webauthn-auth">
  <h2>セキュリティキーで認証</h2>
  <p>セキュリティキーをタッチして認証してください</p>
  
  <button id="webauthn-auth-btn" class="btn btn-primary">
    セキュリティキーで認証
  </button>
  
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const authBtn = document.getElementById('webauthn-auth-btn');
      const options = <%= raw @options.to_json %>;
      
      authBtn.addEventListener('click', async function() {
        try {
          const assertion = await WebAuthnAuthentication.authenticate(options);
          // サーバーに送信
          submitAuthentication(assertion);
        } catch (error) {
          showError('認証に失敗しました: ' + error.message);
        }
      });
    });
  </script>
</div>
```

#### 5.2 管理画面
```erb
<!-- app/views/www/app/setting/passkeys/index.html.erb -->
<div class="webauthn-management">
  <h2>セキュリティキー管理</h2>
  
  <div class="credentials-list">
    <% @credentials.each do |credential| %>
      <div class="credential-item">
        <span class="nickname"><%= credential.nickname %></span>
        <span class="last-used">最終使用: <%= credential.last_used_at&.strftime('%Y/%m/%d %H:%M') || '未使用' %></span>
        <%= link_to '削除', setting_passkey_path(credential), method: :delete, 
                    confirm: 'このセキュリティキーを削除しますか？',
                    class: 'btn btn-danger btn-sm' %>
      </div>
    <% end %>
  </div>
  
  <%= link_to 'セキュリティキーを追加', new_setting_passkey_path, class: 'btn btn-primary' %>
</div>
```

### 6. セキュリティ統合 🔴 **HIGH PRIORITY**

#### 6.1 既存MFAシステムとの統合
```ruby
# app/controllers/concerns/authentication.rb に追加

def require_second_factor_or_webauthn
  return true if webauthn_authenticated?
  return true if totp_authenticated?
  return true if recovery_code_authenticated?
  
  redirect_to_mfa_selection
end

def webauthn_authenticated?
  session[:webauthn_verified_at] && 
  session[:webauthn_verified_at] > 30.minutes.ago
end
```

#### 6.2 セッション管理
```ruby
# セキュリティキー認証成功時
session[:webauthn_verified_at] = Time.current
session[:webauthn_credential_id] = credential.external_id

# ログアウト時
session.delete(:webauthn_verified_at)
session.delete(:webauthn_credential_id)
```

### 7. エラーハンドリング・ユーザビリティ 🟡 **MEDIUM PRIORITY**

#### 7.1 エラーメッセージ
```ruby
# app/controllers/concerns/webauthn_errors.rb
module WebauthnErrors
  WEBAUTHN_ERROR_MESSAGES = {
    'NotAllowedError' => 'セキュリティキーが見つからないか、操作がキャンセルされました',
    'InvalidStateError' => 'このセキュリティキーは既に登録されています',
    'NotSupportedError' => 'お使いのブラウザはセキュリティキーをサポートしていません',
    'SecurityError' => 'セキュアな接続が必要です（HTTPS）',
    'AbortError' => '操作がタイムアウトしました'
  }.freeze

  def webauthn_error_message(error)
    WEBAUTHN_ERROR_MESSAGES[error.name] || 'セキュリティキーの操作中にエラーが発生しました'
  end
end
```

#### 7.2 ブラウザサポート検出
```javascript
// app/javascript/webauthn/utils.js
export function isWebAuthnSupported() {
  return !!(navigator.credentials && navigator.credentials.create);
}

export function showWebAuthnUnsupportedMessage() {
  alert('お使いのブラウザはセキュリティキーをサポートしていません。最新のブラウザをご利用ください。');
}
```

### 8. テスト実装 🟡 **MEDIUM PRIORITY**

#### 8.1 モデルテスト
```ruby
# test/models/webauthn_credential_test.rb
class WebauthnCredentialTest < ActiveSupport::TestCase
  test "should validate presence of required fields" do
    credential = WebauthnCredential.new
    assert_not credential.valid?
    assert_includes credential.errors[:external_id], "can't be blank"
  end
  
  test "should prevent replay attacks" do
    credential = webauthn_credentials(:one)
    assert_not credential.update_sign_count!(credential.sign_count - 1)
  end
end
```

#### 8.2 コントローラーテスト
```ruby
# test/controllers/www/app/setting/passkeys_controller_test.rb
class Www::App::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end
  
  test "should get index" do
    get setting_passkeys_url
    assert_response :success
  end
  
  test "should create webauthn credential" do
    # WebAuthn credential creation test
  end
end
```

### 9. 多ドメイン対応確認 🟡 **MEDIUM PRIORITY**

#### 9.1 各ドメインでの動作確認
- **Corporate domain** (`WWW_CORPORATE_URL`): 基本的な認証機能
- **Service domain** (`WWW_SERVICE_URL`): フル機能（登録・認証・管理）
- **Staff domain** (`WWW_STAFF_URL`): スタッフ用認証機能

#### 9.2 クロスドメイン設定確認
```ruby
# config/webauthn.rb の設定確認
- allowed_origins の正確性
- rp_id の適切な設定（base domain）
- credential の共有可能性
```

### 10. 本番環境対応 🔴 **HIGH PRIORITY**

#### 10.1 環境変数設定
```bash
# 必要な環境変数
WEBAUTHN_RP_NAME="Umaxica"
WEBAUTHN_RP_ID="umaxica.com"  # base domain
WWW_CORPORATE_URL="https://com.umaxica.com"
WWW_SERVICE_URL="https://app.umaxica.com"
WWW_STAFF_URL="https://org.umaxica.com"
```

#### 10.2 HTTPS必須確認
- 本番環境でHTTPS強制
- SSL証明書の有効性確認
- CSP設定の適切性確認

#### 10.3 セキュリティヘッダー
```ruby
# config/application.rb
config.force_ssl = true  # 本番環境で必須

# CSP の WebAuthn 対応確認
Content-Security-Policy: default-src 'self'; connect-src 'self' https:
```

### 11. ドキュメント・運用 🟡 **MEDIUM PRIORITY**

#### 11.1 ユーザー向けガイド
- セキュリティキーの登録方法
- 対応ブラウザ・デバイス一覧
- トラブルシューティング

#### 11.2 管理者向けガイド
- WebAuthn設定の管理
- セキュリティ監視ポイント
- 障害対応手順

#### 11.3 開発者向けドキュメント
- API仕様
- データベーススキーマ
- テスト方法

## 実装優先度

### Phase 1: 基盤実装 🔴 **HIGH PRIORITY**
1. データベース設計・実装
2. モデル実装
3. JavaScript WebAuthn API実装
4. 基本的なコントローラーロジック

### Phase 2: 機能完成 🟡 **MEDIUM PRIORITY**
5. ビュー実装
6. エラーハンドリング
7. テスト実装
8. 多ドメイン対応確認

### Phase 3: 本番対応 🔴 **HIGH PRIORITY**
9. 本番環境設定
10. セキュリティ統合
11. ドキュメント作成

## 推定工数

- **Phase 1**: 3-4人日
- **Phase 2**: 2-3人日
- **Phase 3**: 1-2人日
- **合計**: 6-9人日

## 注意事項

### セキュリティ考慮事項
- WebAuthn challengeの適切な管理
- Replay attack防止（sign_count検証）
- HTTPS環境での運用必須
- Cross-origin設定の慎重な管理

### 既存システムとの互換性
- 既存のTOTP・Recovery Codeシステムとの併用
- セッション管理システムとの統合
- 多ドメインアーキテクチャとの整合性

このタスクリストに従って段階的に実装することで、安全で使いやすいFIDO2セキュリティキー機能を構築できます。