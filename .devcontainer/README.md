# DevContainer Setup for Umaxica App JIT

このDevContainerは、Ruby on Rails 8.0アプリケーションの開発環境をVSCodeで使用するために設定されています。

## 特徴

- **Ruby 3.4.4** + **Rails 8.0**
- **Multi-database設定** (PostgreSQL primary/replica)
- **Bun.js** for asset bundling
- **Karafka** (Kafka-based background jobs)
- **完全な開発ツールチェーン**

## 含まれる拡張機能

### Ruby/Rails開発
- Ruby LSP (Shopify.ruby-lsp)
- Ruby debugger (KoichiSasada.vscode-rdbg)
- RuboCop linting (misogi.ruby-rubocop)
- ERB beautify (aliariff.vscode-erb-beautify)

### フロントエンド開発
- TailwindCSS support (bradlc.vscode-tailwindcss)
- TypeScript support (ms-vscode.vscode-typescript-next)
- Biome formatter (biomejs.biome)

### データベース
- SQLTools (mtxr.sqltools)
- PostgreSQL driver (mtxr.sqltools-driver-pg)

### 生産性向上
- GitHub Copilot (GitHub.copilot)
- GitLens (eamodio.gitlens)
- Test Explorer (hbenl.vscode-test-explorer)

## ポート転送

以下のポートが自動的に転送されます：

- `3000`: Rails Server
- `3333`: Rails Server (Docker)
- `5433`: PostgreSQL Primary
- `5434`: PostgreSQL Replica
- `6379`: Redis
- `9092`: Kafka
- `9200`: Elasticsearch

## VSCodeタスク

`Ctrl+Shift+P` → "Tasks: Run Task" で以下のタスクを実行できます：

- **Rails Server**: Rails サーバーを起動
- **Karafka Server**: Kafka コンシューマーを起動
- **Build Assets**: アセットをビルド
- **Watch Assets**: アセットを監視してリビルド
- **Run Tests**: テストを実行
- **Run Rubocop**: コード品質チェック
- **Fix Rubocop**: コード自動修正
- **Database Migrate**: データベースマイグレーション
- **Database Setup**: データベース初期化
- **Foreman Start Dev**: 全サービスを同時起動

## デバッグ設定

`F5` キーまたはデバッグビューから以下の設定を使用できます：

- **Debug Rails Server**: Rails サーバーをデバッグモードで起動
- **Debug Rails Test**: テストをデバッグ
- **Debug Karafka Server**: Karafka サーバーをデバッグ
- **Attach to Rails Server**: 実行中のRails サーバーにアタッチ

## 使用方法

1. VSCodeでプロジェクトを開く
2. "Reopen in Container" を選択
3. コンテナが構築されるまで待機
4. `Ctrl+Shift+P` → "Tasks: Run Task" → "Foreman Start Dev" で全サービスを起動

## データベース接続

SQLToolsの設定により、VSCode内からPostgreSQLデータベースに直接接続できます：

- **PostgreSQL Primary**: primary:5432
- **PostgreSQL Replica**: replica:5432

## トラブルシューティング

### パーミッション問題
コンテナ起動後に `sudo chown -R main:group /main` が自動実行されます。

### Gem/パッケージ更新
```bash
bundle install
bun install
```

### データベース初期化
```bash
bundle exec rails db:create db:migrate
```