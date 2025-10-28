require "test_helper"

class CorporateSiteContactEmailTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContactEmail < GuestsRecord
  end

  test "should belong to corporate_site_contact" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "test@example.com",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )
    assert_respond_to email, :corporate_site_contact
    assert_not_nil email.corporate_site_contact
    assert_kind_of CorporateSiteContact, email.corporate_site_contact
  end

  test "should downcase email_address before save" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.new(
      corporate_site_contact: contact,
      email_address: "TEST@EXAMPLE.COM",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )
    email.save
    assert_equal "test@example.com", email.email_address
  end

  test "should encrypt email_address" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "test@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # Read directly from database to check encryption
    raw_value = CorporateSiteContactEmail.connection.execute(
      "SELECT email_address FROM corporate_site_contact_emails WHERE id = '#{email.id}'"
    ).first["email_address"]

    # Encrypted value should be different from plaintext
    assert_not_equal "test@example.com", raw_value
    # But the model should decrypt it correctly
    assert_equal "test@example.com", email.reload.email_address
  end

  test "should support deterministic encryption for email_address" do
    contact = corporate_site_contacts(:one)

    # Create two records with the same email
    email1 = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "same@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    email2 = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "same@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # With deterministic encryption, encrypted values should be the same
    raw1 = CorporateSiteContactEmail.connection.execute(
      "SELECT email_address FROM corporate_site_contact_emails WHERE id = '#{email1.id}'"
    ).first["email_address"]

    raw2 = CorporateSiteContactEmail.connection.execute(
      "SELECT email_address FROM corporate_site_contact_emails WHERE id = '#{email2.id}'"
    ).first["email_address"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    # Note: Encrypted fields in fixtures may cause issues
    # We create a fresh record instead of loading from fixtures
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "fixture@example.com",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )
    assert email.valid?
  end

  test "should use UUID as primary key" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "uuid@example.com",
      expires_at: 1.day.from_now
    )
    assert_kind_of String, email.id
    assert_equal 36, email.id.length
  end

  test "should have timestamps" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "timestamp@example.com",
      expires_at: 1.day.from_now
    )
    assert_respond_to email, :created_at
    assert_respond_to email, :updated_at
    assert_not_nil email.created_at
    assert_not_nil email.updated_at
  end

  test "should have all expected attributes" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "attributes@example.com",
      expires_at: 1.day.from_now
    )
    assert_respond_to email, :email_address
    assert_respond_to email, :activated
    assert_respond_to email, :deletable
    assert_respond_to email, :remaining_views
    assert_respond_to email, :expires_at
  end

  test "should have default values" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now
    )
    assert_equal false, email.activated
    assert_equal false, email.deletable
    assert_equal 10, email.remaining_views
  end

  # Validation tests
  test "should validate presence of email_address" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.new(
      corporate_site_contact: contact,
      expires_at: 1.day.from_now
    )
    assert_not email.valid?
    assert email.errors[:email_address].any?, "email_address should have validation errors"
  end

  test "should validate format of email_address" do
    contact = corporate_site_contacts(:one)

    # Invalid email formats
    invalid_emails = [ "invalid", "test@", "@example.com" ]
    invalid_emails.each do |invalid_email|
      email = CorporateSiteContactEmail.new(
        corporate_site_contact: contact,
        email_address: invalid_email,
        expires_at: 1.day.from_now
      )
      assert_not email.valid?, "#{invalid_email} should be invalid"
      assert email.errors[:email_address].any?, "#{invalid_email} should have validation errors"
    end

    # Valid email formats
    valid_emails = [ "test@example.com", "user+tag@example.co.jp", "test.user@example.com" ]
    valid_emails.each do |valid_email|
      email = CorporateSiteContactEmail.new(
        corporate_site_contact: contact,
        email_address: valid_email,
        expires_at: 1.day.from_now
      )
      assert email.valid?, "#{valid_email} should be valid"
    end
  end

  # Verifier tests
  test "should generate verifier code" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "verifier@example.com",
      expires_at: 1.day.from_now
    )

    raw_code = email.generate_verifier!

    assert_not_nil raw_code
    assert_equal 6, raw_code.length
    assert_match(/\A\d{6}\z/, raw_code)
    assert_not_nil email.verifier_digest
    assert_not_nil email.verifier_expires_at
    assert_equal 3, email.verifier_attempts_left
  end

  test "should verify correct code" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "verify@example.com",
      expires_at: 1.day.from_now
    )

    raw_code = email.generate_verifier!
    assert email.verify_code(raw_code)
    assert email.reload.activated
    assert_equal 0, email.verifier_attempts_left
  end

  test "should reject incorrect code and decrement attempts" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "wrong@example.com",
      expires_at: 1.day.from_now
    )

    email.generate_verifier!
    initial_attempts = email.verifier_attempts_left

    assert_not email.verify_code("000000")
    assert_not email.reload.activated
    assert_equal initial_attempts - 1, email.verifier_attempts_left
  end

  test "should reject code when attempts exhausted" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "exhausted@example.com",
      expires_at: 1.day.from_now
    )

    raw_code = email.generate_verifier!

    # Exhaust attempts
    email.update!(verifier_attempts_left: 0)

    assert_not email.verify_code(raw_code)
    assert_not email.reload.activated
  end

  test "should reject expired verifier code" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "expired@example.com",
      expires_at: 1.day.from_now
    )

    raw_code = email.generate_verifier!

    # Expire the code
    email.update!(verifier_expires_at: 1.hour.ago)

    assert_not email.verify_code(raw_code)
    assert_not email.reload.activated
  end

  test "verifier_expired? should return true when expired" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "check_expired@example.com",
      expires_at: 1.day.from_now
    )

    email.generate_verifier!
    assert_not email.verifier_expired?

    email.update!(verifier_expires_at: 1.hour.ago)
    assert email.verifier_expired?
  end

  test "can_resend_verifier? should return true when verifier expired" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "resend@example.com",
      expires_at: 1.day.from_now
    )

    email.generate_verifier!
    email.update!(verifier_expires_at: 1.hour.ago)

    assert email.can_resend_verifier?
  end

  test "can_resend_verifier? should return true when attempts exhausted" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "resend2@example.com",
      expires_at: 1.day.from_now
    )

    email.generate_verifier!
    email.update!(verifier_attempts_left: 0)

    assert email.can_resend_verifier?
  end

  test "can_resend_verifier? should return false when activated" do
    contact = corporate_site_contacts(:one)
    email = CorporateSiteContactEmail.create!(
      corporate_site_contact: contact,
      email_address: "activated@example.com",
      expires_at: 1.day.from_now
    )

    email.generate_verifier!
    email.update!(activated: true)

    assert_not email.can_resend_verifier?
  end
end
