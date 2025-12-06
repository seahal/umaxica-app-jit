#!/usr/bin/env ruby
# Test script for telephone verification email

puts "=" * 70
puts "  電話番号検証メール送信テスト"
puts "=" * 70
puts ""

# Find the most recent contact with SET_UP status
contact = ComContact.where(contact_status_title: 'SET_UP').order(created_at: :desc).first

unless contact
  # Create a test contact
  puts "テスト用のコンタクトを作成します..."
  contact = ComContact.create!(
    contact_category_title: "CORPORATE_INQUIRY",
    contact_status_title: "SET_UP",
    public_id: "test_#{SecureRandom.hex(8)}"
  )

  # Create email
  contact_email = ComContactEmail.create!(
    com_contact: contact,
    email_address: "test@example.com"
  )

  # Create telephone
  contact_telephone = ComContactTelephone.create!(
    com_contact: contact,
    telephone_number: "+15555555555"
  )

  puts "✅ テストコンタクトを作成しました"
  puts "   - Contact ID: #{contact.public_id}"
  puts "   - Email: #{contact_email.email_address}"
  puts "   - Telephone: #{contact_telephone.telephone_number}"
  puts ""
end

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
  rescue => e
    puts "❌ メール送信エラー: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
else
  puts "❌ メールまたは電話番号レコードが見つかりません"
end

puts ""
