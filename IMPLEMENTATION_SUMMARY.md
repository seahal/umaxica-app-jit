# 電話番号E.164正規化実装まとめ

## 実装完了ファイル

### 1. Concern (正規化ロジック)
- **[app/models/concerns/telephone_normalization.rb](app/models/concerns/telephone_normalization.rb)**
  - E.164形式への正規化ロジック
  - バリデーション（形式、長さ、国番号）
  - 再利用可能なmodule

### 2. 既存Concern更新
- **[app/models/concerns/telephone.rb](app/models/concerns/telephone.rb)**
  - `TelephoneNormalization` を include
  - 古いバリデーション（length: 3..20, format）を削除
  - `normalize_telephone_field :number` を追加

### 3. モデル更新

#### Identity/Authentication
- **[app/models/user_telephone.rb](app/models/user_telephone.rb)**
  - 重複する `encrypts :number` 削除
  - 重複するバリデーション削除（Telephone concernで処理）

- **[app/models/staff_telephone.rb](app/models/staff_telephone.rb)**
  - UserTelephoneと同様の更新

#### Contact (Guest)
- **[app/models/app_contact_telephone.rb](app/models/app_contact_telephone.rb)**
  - `TelephoneNormalization` を include
  - `normalize_telephone_field :telephone_number` を追加

- **[app/models/com_contact_telephone.rb](app/models/com_contact_telephone.rb)**
  - App と同様

- **[app/models/org_contact_telephone.rb](app/models/org_contact_telephone.rb)**
  - App と同様

#### Occurrence (Risk/Fraud Detection)
- **[app/models/telephone_occurrence.rb](app/models/telephone_occurrence.rb)**
  - `TelephoneNormalization` を include
  - `normalize_telephone_field :body` を追加

### 4. i18n (エラーメッセージ)
- **[config/locales/en.yml](config/locales/en.yml)**
  - `invalid_e164_format`: E.164形式エラー
  - `exceeds_e164_length`: 長さ超過エラー
  - `country_code_cannot_start_with_zero`: 国番号0始まりエラー

- **[config/locales/jp/ja.yml](config/locales/jp/ja.yml)**
  - 日本語版エラーメッセージ

### 5. テスト
- **[test/models/concerns/telephone_normalization_test.rb](test/models/concerns/telephone_normalization_test.rb)**
  - 正規化ロジックのunit tests (27 tests)

- **[test/models/user_telephone_test.rb](test/models/user_telephone_test.rb)**
  - E.164正規化テストを追加 (18 new tests)

- **[test/models/telephone_occurrence_test.rb](test/models/telephone_occurrence_test.rb)**
  - E.164正規化テストを追加 (7 new tests)

## 正規化仕様

### 入力形式
以下の入力を受け付け、E.164形式に正規化：

1. **国内形式（日本）**
   - `090-1234-5678` → `+819012345678`
   - `03-1234-5678` → `+81312345678`
   - ハイフン、スペース、括弧などを自動除去

2. **国際発信プレフィックス**
   - `0081 90 1234 5678` → `+819012345678` (明示的な(0)がある場合)
   - `010 81 90 1234 5678` → `+819012345678` (明示的な(0)がある場合)
   - `0081(0)90-1234-5678` → `+819012345678`

3. **既にE.164形式**
   - `+819012345678` → `+819012345678` (そのまま)
   - `+81 90 1234 5678` → `+819012345678` (スペース除去)

4. **国際番号**
   - `+1 (555) 123-4567` → `+15551234567` (US)
   - 各国の形式に対応

### 除去する文字
- 半角/全角スペース
- ハイフン (-, ‐, −, –, —)
- 括弧 ((, ), （, ）)
- ドット (.)
- スラッシュ (/)
- 中点 (・)

### バリデーション
1. **E.164形式**: `\A\+[1-9]\d{1,14}\z`
2. **最大長**: 16文字 (+と15桁)
3. **国番号**: 0で始まらない
4. **必須**: 空白不可

### エラーケース
以下は無効として`nil`を返す：
- `9012345678` (先頭0または+なし - 曖昧)
- `+0123456789` (国番号が0始まり)
- `(---)` (数字なし)
- 空文字列/空白のみ

## テスト実行方法

```bash
# 正規化ロジックのunit test
bin/rails test test/models/concerns/telephone_normalization_test.rb

# UserTelephoneのmodel test
bin/rails test test/models/user_telephone_test.rb

# TelephoneOccurrenceのmodel test
bin/rails test test/models/telephone_occurrence_test.rb

# 全テスト
bin/rails test
```

## 注意点

### 1. スキーマ変更なし
- 新規カラム追加不要
- 既存カラムをそのまま使用:
  - `number` (UserTelephone, StaffTelephone)
  - `telephone_number` (ContactTelephones)
  - `body` (TelephoneOccurrence)

### 2. 暗号化との互換性
- 正規化は `before_validation` で実行
- 暗号化は正規化後に実行（deterministic encryption）
- 同じ番号は同じ暗号文→一意性チェック可能

### 3. 既存データ
- 既存データは旧形式のまま
- 新規保存時に自動正規化
- マイグレーション不要（データ移行は別タスク）

### 4. 制限事項
- デフォルト国: 日本 (country code 81)
- 国内0無しの曖昧な入力（`9012345678`）は拒否
- スペース区切りの国際プレフィックス（`0081 90...`）は、明示的な`(0)`がない場合、意図通りに正規化されない可能性あり（実用上は稀）

## 実装戦略

1. **最小限の変更**: 既存コードの破壊を最小化
2. **後方互換性**: 既存のTelephone concernを拡張
3. **段階的導入**: 新規データから適用
4. **テストカバレッジ**: 主要ケースをカバー
