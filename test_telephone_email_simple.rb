#!/usr/bin/env ruby
# Test script for telephone verification email (using existing data)

puts "=" * 70
puts "  電話番号検証メール送信テスト"
puts "=" * 70
puts ""

# Find the most recent contact with CHECKED_EMAIL_ADDRESS status
contact = ComContact.where(contact_status_title: 'CHECKED_EMAIL_ADDRESS').order(created_at: :desc).first

if contact
  contact_email = contact.com_contact_emails.first
  contact_telephone = contact.com_contact_telephones.first

  if contact_email && contact_telephone
    puts "📋 コンタクト情報:"
    puts "   - Contact ID: #{contact.public_id}"
    puts "   - Status: #{contact.contact_status_title}"
    puts "   - Email: #{contact_email.email_address}"
    puts "   - Telephone: #{contact_telephone.telephone_number}"
    puts ""

    # Generate HOTP code
    puts "🔄 電話番号検証用HOTPコードを生成..."
    telephone_token = contact_telephone.generate_hotp!

    puts "✅ コード生成完了: #{telephone_token}"
    puts ""

    # Send email
    puts "📧 メール送信テスト..."
    begin
      Email::Com::ContactTelephoneMailer.with(
        email_address: contact_email.email_address,
        pass_code: telephone_token
      ).verify.deliver_now

      puts "✅ メール送信成功！"
      puts ""
      puts "=" * 70
      puts "  送信されたメール内容"
      puts "=" * 70
      puts "  宛先: #{contact_email.email_address}"
      puts "  件名: UMAXICA - Telephone Verification Code"
      puts ""
      puts "  【認証コード】"
      puts "    ┌─────────────────┐"
      puts "    │   #{telephone_token}   │"
      puts "    └─────────────────┘"
      puts ""
      puts "  - 有効期限: 10分"
      puts "  - 残り試行回数: #{contact_telephone.verifier_attempts_left}回"
      puts "=" * 70
      puts ""
      puts "✅ テスト完了！"
    rescue => e
      puts "❌ メール送信エラー: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  else
    puts "❌ メールまたは電話番号レコードが見つかりません"
  end
else
  puts "❌ CHECKED_EMAIL_ADDRESS ステータスのコンタクトが見つかりません"
  puts ""
  puts "最新のコンタクト一覧:"
  ComContact.order(created_at: :desc).limit(3).each do |c|
    puts "  - #{c.public_id} (#{c.contact_status_title})"
  end
end

puts ""
