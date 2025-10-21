# Social Login Implementation Plan

## Overview
複数のソーシャルログインプロバイダー（Google, Apple, Facebook等）に対応する拡張可能なアーキテクチャを実装する。

## Current State
- OAuth gems already installed (omniauth, omniauth-google-oauth2, omniauth-apple)
- Database models and migrations created but not enabled
- Controller and view stubs created but not implemented
- Routes defined but incomplete

## Architecture Design

### 1. 統一されたOAuthサービス層
```
app/services/oauth/
├── base_service.rb          # 共通ロジック
├── providers/
│   ├── google_service.rb    # Google固有の処理
│   ├── apple_service.rb     # Apple固有の処理
│   └── facebook_service.rb  # 将来追加用
```

**BaseService responsibilities:**
- OAuth認証フローの共通処理
- ユーザーデータの正規化
- エラーハンドリング
- ログ記録

**Provider-specific services:**
- プロバイダー固有のAPI呼び出し
- レスポンスデータの変換
- プロバイダー特有の制約対応

### 2. プロバイダー設定システム
```yaml
# config/oauth_providers.yml
providers:
  google:
    name: "Google"
    icon: "google"
    enabled: true
    scopes: ["email", "profile"]
  apple:
    name: "Apple" 
    icon: "apple"
    enabled: true
    scopes: ["name", "email"]
  facebook:
    name: "Facebook"
    icon: "facebook"
    enabled: false
    scopes: ["email", "public_profile"]
```

### 3. 共通コントローラーConcern
```ruby
# app/controllers/concerns/oauth_authentication.rb
module OauthAuthentication
  extend ActiveSupport::Concern
  
  included do
    before_action :validate_provider
    rescue_from OmniAuth::Error, with: :oauth_error
  end
  
  private
  
  def oauth_callback
    # 全プロバイダー共通の認証処理
  end
  
  def oauth_error
    # エラーハンドリング
  end
end
```

### 4. 柔軟なビューコンポーネント
```ruby
# app/components/oauth_button_component.rb
class OauthButtonComponent < ViewComponent::Base
  def initialize(provider:, action: :authenticate, size: :medium)
    @provider = provider
    @action = action
    @size = size
  end
  
  private
  
  attr_reader :provider, :action, :size
  
  def provider_config
    @provider_config ||= OauthProviders.find(provider)
  end
  
  def oauth_path
    case action
    when :authenticate
      send("new_www_app_authentication_#{provider}_path")
    when :register
      send("new_www_app_registration_#{provider}_path")
    end
  end
end
```

### 5. 統一ルート設計
```ruby
# config/routes/www.rb内でのDRY化
OauthProviders.enabled.each do |provider|
  # Registration routes
  namespace :registration do
    resource provider.to_sym, only: [:new, :create]
  end
  
  # Authentication routes  
  namespace :authentication do
    resource provider.to_sym, only: [:new, :create]
  end
  
  # Settings routes
  namespace :setting do
    resource provider.to_sym, only: [:show, :destroy]
  end
end

# OAuth callbacks
get '/sign/:provider/callback', to: 'oauth_callbacks#create'
get '/sign/failure', to: 'oauth_callbacks#failure'
```

## Implementation Steps

### Phase 1: Core Infrastructure
1. **Enable database migrations**
   - Uncomment and run Google/Apple OAuth migrations
   - Add indexes for performance

2. **Create Omniauth initializer**
   ```ruby
   # config/initializers/omniauth.rb
   Rails.application.config.middleware.use OmniAuth::Builder do
     OauthProviders.enabled.each do |provider|
       provider provider.omniauth_key, 
                ENV["#{provider.env_prefix}_CLIENT_ID"],
                ENV["#{provider.env_prefix}_CLIENT_SECRET"],
                provider.omniauth_options
     end
   end
   ```

3. **Add OAuth callback routes**
   - Define unified callback handling
   - Add error handling routes

### Phase 2: Service Layer
1. **Create OAuth base service**
   - Common authentication flow
   - User creation/lookup logic
   - Session management

2. **Implement provider-specific services**
   - Google OAuth service
   - Apple OAuth service
   - Extensible for future providers

### Phase 3: Controller Implementation
1. **Create OAuth concern**
   - Shared controller logic
   - Error handling
   - Security measures

2. **Implement controller actions**
   - Registration flow
   - Authentication flow
   - Account linking

### Phase 4: UI Components
1. **Create OAuth button component**
   - Flexible design system
   - Multiple sizes and styles
   - Provider-specific branding

2. **Update authentication views**
   - Add social login options
   - Maintain existing email/phone flows
   - Progressive enhancement

### Phase 5: Configuration & Security
1. **Environment variables setup**
   - Client IDs and secrets
   - Provider-specific configuration
   - Development vs production settings

2. **Security enhancements**
   - CSRF protection
   - State parameter validation
   - Rate limiting

## Benefits of This Architecture

1. **Extensibility**: 新しいプロバイダーの追加が容易
2. **Maintainability**: 共通ロジックの集約により保守性向上
3. **Consistency**: 統一されたUI/UXとエラーハンドリング
4. **Testability**: 各レイヤーの独立したテストが可能
5. **Configuration**: 環境ごとの柔軟な設定管理

## Testing Strategy

1. **Unit Tests**
   - Service layer logic
   - Component rendering
   - Model validations

2. **Integration Tests**
   - OAuth flow end-to-end
   - Error scenarios
   - Security measures

3. **System Tests**
   - User authentication journeys
   - Cross-browser compatibility
   - Mobile responsiveness

## Environment Variables Required

```bash
# Google OAuth
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret

# Apple OAuth  
APPLE_CLIENT_ID=your_client_id
APPLE_CLIENT_SECRET=your_client_secret
APPLE_TEAM_ID=your_team_id
APPLE_KEY_ID=your_key_id
APPLE_PRIVATE_KEY=your_private_key

# Facebook OAuth (future)
FACEBOOK_CLIENT_ID=your_client_id
FACEBOOK_CLIENT_SECRET=your_client_secret
```

## Next Steps

1. Review and approve this architecture plan
2. Begin Phase 1 implementation
3. Set up development environment with OAuth credentials
4. Create comprehensive test suite
5. Document API endpoints and integration guides