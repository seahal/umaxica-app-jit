# Legal Compliance & Forensic Audit Plan

Created: 2026-03-27

## Goal

法的要請があった際に、即座に証拠として提出できる監査ログ基盤を構築する。
全通知チャネルの証跡、改ざん検知 + 外部証明（TSA）、長期保存（WORM）の 3 層で証拠力を担保する。

GitHub Issues: #554 (Phase 1), #555 (Phase 2), #556 (Phase 3)

---

## Phase 1: 全通知チャネル・認証フローの証跡記録 (#554)

### P1-1: SMS 配信証跡（新規）

- [ ] `sms_activities`, `sms_activity_events`, `sms_activity_levels` テーブル作成
- [ ] `SmsActivity`, `SmsActivityEvent`, `SmsActivityLevel` モデル実装
- [ ] `AwsSmsService` / `SmsDeliveryJob` に証跡記録を追加
- [ ] AWS SNS Delivery Status Logging の取り込み

### P1-2: Email 配信証跡（新規）

- [ ] `email_activities`, `email_activity_events`, `email_activity_levels` テーブル作成
- [ ] `EmailActivity`, `EmailActivityEvent`, `EmailActivityLevel` モデル実装
- [ ] ActionMailer に証跡記録を追加
- [ ] AWS SES イベント通知の取り込み（Delivery/Bounce/Complaint）

### P1-3: 既存認証フローの記録漏れ調査・修正

- [ ] Social Login (Google/Apple): AuditWriter 呼び出し確認 + context 充実
- [ ] Passkey: 登録・認証・削除の記録確認 + WebAuthn credential ID を context に
- [ ] Secret Key: 作成・使用・更新・削除の記録確認 + key fingerprint を context に
- [ ] TOTP: enable/disable/verify の記録確認
- [ ] Step-up: 認証方法を context に記録
- [ ] Staff 側の同等カバレッジ確認

### P1-4: 法的提出用エクスポート

- [ ] `AuditExporter` サービス（JSON Lines + SHA256 ハッシュ + Merkle root）
- [ ] Rake タスク: `rake legal:export[type,from,to]`

### P1-5: テスト

- [ ] 全モデルテスト、配信記録テスト、エクスポート形式テスト

---

## Phase 2: ハッシュチェーン + 認定タイムスタンプ（TSA）(#555)

内部ハッシュチェーンだけでは法的信用力が弱い（自己証明）ため、
認定タイムスタンプ局（TSA）による外部証明をセットで実装する。

### P2-1: ハッシュチェーン基盤

- [ ] 全 activity テーブルに `digest`（string, NOT NULL）+ `sequence_number`（bigint, NOT NULL）追加
- [ ] AuditWriter にチェーン計算を組み込み（SHA256, genesis digest, トランザクション保護）
- [ ] `AuditChainVerifier` サービス + Rake タスク

### P2-2: 認定タイムスタンプ（TSA）連携

- [ ] 日本認定 TSA プロバイダー選定（RFC 3161 対応）
- [ ] `Tsa::Client` サービス実装（RFC 3161 TimeStampReq/TimeStampResp）
- [ ] `AuditTimestampJob`（1 時間バッチ）: Merkle root → TSA 送信 → トークン保存
- [ ] `audit_timestamps` テーブル作成（TSA レスポンス保存）
- [ ] `AuditTimestampVerifier` サービス + Rake タスク

### P2-3: 失敗補償

- [ ] Dead letter queue（SolidQueue）+ `AuditRetryJob`（指数バックオフ、最大 10 回）
- [ ] 最終失敗時の管理者通知 + チェーン修復手順文書化

### P2-4: テスト

- [ ] チェーン連続性、改ざん検知、ギャップ検知、並行書き込み
- [ ] Merkle tree 計算、TSA リクエスト/レスポンス、タイムスタンプ検証
- [ ] Dead letter queue + リトライ

---

## Phase 3: S3 Object Lock（WORM）への定期アーカイブ (#556)

### P3-1: S3 Object Lock バケットのセットアップ

- [ ] Terraform / CloudFormation で Object Lock 有効バケット作成
  - Object Lock: Compliance モード、保持期間 7 年
  - バージョニング有効、SSE-S3 or SSE-KMS 暗号化
- [ ] IAM ポリシー: PutObject のみ（削除・上書き不可）
- [ ] セットアップ手順を docs/ に文書化

### P3-2: 定期エクスポートジョブ

- [ ] `LegalArchiveExportJob`（SolidQueue、1 時間ごと）
  - JSON Lines + Merkle root + TSA トークン参照を S3 に PUT
  - キー: `activity/{table}/{YYYY}/{MM}/{DD}/{HH}.jsonl`
- [ ] エクスポートメタデータの記録 + 失敗時アラート

### P3-3: アーカイブ検証ツール

- [ ] `LegalArchiveVerifier`: S3 と activity DB の突合 + Merkle root 照合
- [ ] Rake タスク: `rake legal:verify:archive[date]`

### P3-4: テスト

- [ ] エクスポートジョブ単体テスト、JSON Lines 形式テスト、Merkle root 検証テスト

---

## 優先順位

1. **Phase 1**（通知証跡 + 認証記録漏れ修正）— 法的リスクが最も高い領域
2. **Phase 2**（ハッシュチェーン + TSA）— 改ざん検知 + 外部証明で証拠力を確保
3. **Phase 3**（S3 WORM）— 長期保存と物理的な改ざん不可能性の担保
