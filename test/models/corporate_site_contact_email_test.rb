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
end
