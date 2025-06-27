# Fastly マルチテナント エラーハンドリング

## 概要

FastlyのVCLを使用して、マルチテナント対応のエラーページを配信する仕組み。
URLを変更せず、ドメインに応じた適切なエラーページを表示する。

## 処理フロー

### 404エラーの場合

1. **ユーザーアクセス**
   ```
   ユーザー → https://umaxica.com/naisaito にアクセス
   ```

2. **Fastly → Rails転送**
   ```
   Fastly → Railsアプリケーションに転送
   ```

3. **Rails 404エラー**
   ```
   Rails → 404エラーを返す（存在しないページ）
   ```

4. **Fastly VCL処理**
   ```
   Fastly VCL → vcl_errorで404をキャッチ
   ```

5. **外部静的ファイル取得**
   ```
   Fastly → Cloudflareから対応する404.htmlを取得
   - umaxica.com → /com/404.html
   - umaxica.app → /app/404.html  
   - umaxica.org → /org/404.html
   ```

6. **ユーザーへ配信**
   ```
   Fastly → ユーザーに404.htmlを配信（URLは変更なし）
   ```

## VCL実装イメージ

```vcl
sub vcl_error {
  if (obj.status == 404 || obj.status == 500) {
    # ドメインに応じたエラーページパスを設定
    if (req.http.host == "umaxica.com") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/com/" + obj.status + ".html";
    } else if (req.http.host == "umaxica.app") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/app/" + obj.status + ".html";
    } else if (req.http.host == "umaxica.org") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/org/" + obj.status + ".html";
    }
    
    set bereq.http.host = "errors.cloudflare.com";
    restart;
  }
}
```

## メリット

- **URL不変**: ユーザーのアドレスバーは元のURLのまま
- **独立性**: メインサイトダウン時でもエラーページは表示
- **パフォーマンス**: 静的ファイルの高速配信
- **ブランディング**: ドメインごとに異なるエラーページ
- **コスト効率**: 静的ファイルホスティングは安価

## 静的ファイル配置先候補

- Cloudflare Pages
- AWS S3
- Google Cloud Storage  
- Netlify
- GitHub Pages

## 現在の状況

- ✅ Rails側にドメイン別エラーページ作成済み
  - `public/com/404.html`, `public/com/500.html`
  - `public/app/404.html`, `public/app/500.html`
  - `public/org/404.html`, `public/org/500.html`
- ⏳ Fastly VCL設定（今後実装予定）
- ⏳ 外部静的ファイルホスト選定・設定（今後実装予定）