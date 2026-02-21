# アプリケーション・アーキテクチャガイドライン

## 目指すアーキテクチャ
本プロジェクトは **「MVC + Service + Form」** を標準のアーキテクチャとします。
これはFat ControllerやFat Modelを防ぐため、Railsのレールに沿いつつ適切に責務を分割するアプローチです。

## 各ディレクトリの役割

### 1. `app/controllers` (Controller)
**役割:**
- リクエストのルーティング
- パラメータの受け取りとForm/Serviceへの引き渡し
- レスポンス（HTML, JSON, リダイレクトなど）の返却

**ルール:**
- ビジネスロジックを直接記述しないこと（Controllerのメソッドの行数はできるだけ抑える）。
- 複雑なクエリの組み立てや、複数のDBを巻き込んだ保存操作は `Form` や `Service` に委譲する。

### 2. `app/models` (Model)
**役割:**
- データベースと直結する振る舞い
- データベースの構造に依存したバリデーション（ユニーク制約など）
- スコープやテーブル情報の取得

**ルール:**
- **単一モデルに閉じた知識のみ**を持つようにする。
- 外部APIとの通信や、他の複数モデルをまたぐようなトランザクション処理を含めない（Fat Modelの防止）。

---

### 3. `app/forms` (Form)
**役割:**
- リクエストから受け取ったデータの検証（ビジネス要求に基づいた複雑なバリデーション）
- 複数のモデルに対するデータ加工や、矛盾のない同時保存を一貫性を持たせて行う処理

**ベースクラス:** `ApplicationForm` （`ActiveModel::Model` と `ActiveModel::Attributes` を包含）

**実装サンプル:**
```ruby
class UserRegistrationForm < ApplicationForm
  attribute :email, :string
  attribute :password, :string
  attribute :profile_name, :string

  validates :email, :password, :profile_name, presence: true

  def save
    return false unless valid?
    
    ActiveRecord::Base.transaction do
      user = User.create!(email: email, password: password)
      user.create_profile!(name: profile_name)
    end
    true
  rescue ActiveRecord::RecordInvalid
    # バリデーションエラーやDB制約違反などのハンドリング
    errors.add(:base, "登録に失敗しました")
    false
  end
end
```

---

### 4. `app/services` (Service)
**役割:**
- 決済、メールの送信、外部APIとの連携といった「複雑なドメインロジック」の実行
- ControllerやBackground Jobから呼び出される、純粋なRubyとしての処理（トランザクションスクリプト）

**ベースクラス:** `ApplicationService`
**ルール:**
- 原則として **単一責任（クラス１つにつき、やることは１つ）** とし、公開メソッドは `#call` のみを持たせること。

**実装サンプル:**
```ruby
class SendWelcomeEmailService < ApplicationService
  def initialize(user:)
    @user = user
  end

  def call
    return false unless @user.active?

    # 外部APIの呼び出しや複雑な条件判断など、
    # Modelに持たせるべきではないロジックをここに記述する
    Mailer.welcome(@user).deliver_now
    
    # 成功時にイベントログを記録するなど
    Rails.event.record("user.welcomed", user_id: @user.id)
    true
  end
end
```
**呼び出し方:** `SendWelcomeEmailService.call(user: current_user)`

---

## バックグラウンド処理について
### `app/jobs` (Job)
**役割:**
- 重い処理（一括データ更新、時間のかかる外部API通信、ファイル生成など）の非同期実行
- アプリケーションでは `Solid Queue` (ActiveJob) をバックエンドとして利用します。

**制限事項:**
- Jobの中で複雑なロジックを0から書くのではなく、できる限り **`Service.call` を呼び出す薄いラッパー** として設計することが推奨されます。
