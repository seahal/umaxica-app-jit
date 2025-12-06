#!/usr/bin/env ruby
# Script to check or generate HOTP code for email verification

puts "=" * 70
puts "  メールアドレス検証用 HOTP コード確認"
puts "=" * 70
puts ""

# Find the most recent contact
contact = ComContact.order(created_at: :desc).first

if contact
  puts "📋 最新のコンタクト情報:"
  puts "  - ID: #{contact.public_id}"
  puts "  - ステータス: #{contact.contact_status_title}"
  puts "  - 作成日時: #{contact.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
  puts ""

  email = contact.com_contact_emails.first

  if email
    puts "📧 メールアドレス情報:"
    puts "  - Email: #{email.email_address}"
    puts "  - 認証済み: #{email.activated ? 'はい' : 'いいえ'}"

    if email.verifier_expires_at
      puts "  - 有効期限: #{email.verifier_expires_at.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "  - 残り試行回数: #{email.verifier_attempts_left}回"

      if email.verifier_expires_at > Time.current && email.verifier_attempts_left > 0
        puts "  - ⚠️  現在のコードはまだ有効です"
        puts ""
        puts "新しいコードを生成しますか？ (既存のコードは無効になります)"
        puts "続行する場合は、スクリプトに 'force' オプションを追加してください"
      else
        puts "  - ❌ コードが期限切れまたは試行回数超過"
        puts ""
        puts "🔄 新しいHOTPコードを生成します..."
        code = email.generate_hotp!

        puts ""
        puts "=" * 70
        puts "  📨 メール送信内容 (#{email.email_address})"
        puts "=" * 70
        puts ""
        puts "  件名: #{ENV.fetch('BRAND_NAME', 'Umaxica')} - Email Verification Code"
        puts ""
        puts "  【6桁の認証コード】"
        puts ""
        puts "    ┌─────────────────┐"
        puts "    │   #{code}   │"
        puts "    └─────────────────┘"
        puts ""
        puts "  - このコードは10分間有効です"
        puts "  - 残り試行回数: #{email.verifier_attempts_left}回"
        puts "  - 有効期限: #{email.verifier_expires_at.strftime('%Y-%m-%d %H:%M:%S')}"
        puts ""
        puts "=" * 70
      end
    else
      puts ""
      puts "🔄 新しいHOTPコードを生成します..."
      code = email.generate_hotp!

      puts ""
      puts "=" * 70
      puts "  📨 メール送信内容 (#{email.email_address})"
      puts "=" * 70
      puts ""
      puts "  件名: #{ENV.fetch('BRAND_NAME', 'Umaxica')} - Email Verification Code"
      puts ""
      puts "  【6桁の認証コード】"
      puts ""
      puts "    ┌─────────────────┐"
      puts "    │   #{code}   │"
      puts "    └─────────────────┘"
      puts ""
      puts "  - このコードは10分間有効です"
      puts "  - 残り試行回数: #{email.verifier_attempts_left}回"
      puts "  - 有効期限: #{email.verifier_expires_at.strftime('%Y-%m-%d %H:%M:%S')}"
      puts ""
      puts "=" * 70
    end
  else
    puts "❌ メールアドレスレコードが見つかりません"
  end
else
  puts "❌ コンタクトが見つかりません"
  puts ""
  puts "問い合わせフォームから新しいコンタクトを作成してください。"
end

puts ""
