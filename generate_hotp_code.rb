#!/usr/bin/env ruby
# Script to generate HOTP code for telephone verification

contact = ComContact.where(contact_status_title: 'CHECKED_EMAIL_ADDRESS').order(created_at: :desc).first

if contact
  puts "Contact found: #{contact.public_id}"
  telephone = contact.com_contact_telephones.first

  if telephone
    puts "Telephone: #{telephone.telephone_number}"

    # Generate a new HOTP code
    code = telephone.generate_hotp!

    puts "\n" + "=" * 60
    puts "  6桁のHOTPコード: #{code}"
    puts "=" * 60
    puts "このコードは10分間有効です"
    puts "残り試行回数: #{telephone.verifier_attempts_left}回"
    puts "有効期限: #{telephone.verifier_expires_at.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "=" * 60
  else
    puts 'ERROR: Telephone record not found for this contact'
  end
else
  puts 'No contact found with CHECKED_EMAIL_ADDRESS status'
  puts "\n全てのコンタクト:"
  ComContact.order(created_at: :desc).limit(5).each do |c|
    puts "  - ID: #{c.public_id}, Status: #{c.contact_status_title}"
  end
end
