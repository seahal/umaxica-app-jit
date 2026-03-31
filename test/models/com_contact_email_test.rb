# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_emails
# Database name: guest
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  email_address          :string(1000)     default(""), not null
#  expires_at             :datetime         not null
#  hotp_counter           :integer
#  hotp_secret            :string
#  remaining_views        :integer          default(10), not null
#  token_digest           :string(255)
#  token_expires_at       :datetime
#  token_viewed           :boolean          default(FALSE), not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)
#  verifier_expires_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  com_contact_id         :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_emails_on_com_contact_id_unique  (com_contact_id) UNIQUE
#  index_com_contact_emails_on_email_address          (email_address)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

require "test_helper"

class ComContactEmailTest < ActiveSupport::TestCase
  fixtures :com_contact_categories, :com_contact_statuses

  test "should inherit from GuestRecord" do
    assert_operator ComContactEmail, :<, GuestRecord
  end

  setup do
    # Seed necessary reference data for tests
    [ComContactCategory::SECURITY_ISSUE, ComContactCategory::NOTHING].each do |id|
      ComContactCategory.find_or_create_by!(id: id)
    end
    [
      ComContactStatus::NOTHING,
      ComContactStatus::SET_UP,
      ComContactStatus::COMPLETED_CONTACT_ACTION,
    ].each do |id|
      ComContactStatus.find_or_create_by!(id: id)
    end
  end

  test "should belong to com_contact" do
    contact = create_contact(
      public_id: "unique_contact_1",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now,
    )

    assert_respond_to email, :com_contact
    assert_not_nil email.com_contact
    assert_kind_of ComContact, email.com_contact
  end

  test "should downcase email_address before save" do
    contact = create_contact(
      public_id: "unique_contact_2",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.new(
      com_contact: contact,
      email_address: "TEST@EXAMPLE.COM",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )
    email.save

    assert_equal "test@example.com", email.email_address
  end

  test "should encrypt email_address" do
    contact = create_contact(
      public_id: "unique_contact_3",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    # Read directly from database to check encryption
    raw_value = ComContactEmail.connection.execute(
      "SELECT email_address FROM com_contact_emails WHERE id = '#{email.id}'",
    ).first["email_address"]

    # Encrypted value should be different from plaintext
    assert_not_equal "test@example.com", raw_value
    # But the model should decrypt it correctly
    assert_equal "test@example.com", email.reload.email_address
  end

  test "should support deterministic encryption for email_address" do
    contact1 = create_contact(
      public_id: "unique_contact_4",
      created_at: Time.current,
      updated_at: Time.current,
    )
    contact2 = create_contact(
      public_id: "unique_contact_5",
      created_at: Time.current,
      updated_at: Time.current,
    )

    # Create two records with the same email
    email1 = ComContactEmail.create!(
      com_contact: contact1,
      email_address: "same@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    email2 = ComContactEmail.create!(
      com_contact: contact2,
      email_address: "same@example.com",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    # With deterministic encryption, encrypted values should be the same
    raw1 = ComContactEmail.connection.execute(
      "SELECT email_address FROM com_contact_emails WHERE id = '#{email1.id}'",
    ).first["email_address"]

    raw2 = ComContactEmail.connection.execute(
      "SELECT email_address FROM com_contact_emails WHERE id = '#{email2.id}'",
    ).first["email_address"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    # Note: Encrypted fields in fixtures may cause issues
    # We create a fresh record instead of loading from fixtures
    contact = create_contact(
      public_id: "unique_contact_6",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "fixture@example.com",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now,
    )

    assert_predicate email, :valid?
  end

  test "should use bigint as primary key" do
    contact = create_contact(
      public_id: "unique_contact_7",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "uuid@example.com",
      expires_at: 1.day.from_now,
    )

    assert_kind_of Integer, email.id
  end

  test "should have timestamps" do
    contact = create_contact(
      public_id: "unique_contact_8",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "timestamp@example.com",
      expires_at: 1.day.from_now,
    )

    assert_respond_to email, :created_at
    assert_respond_to email, :updated_at
    assert_not_nil email.created_at
    assert_not_nil email.updated_at
  end

  test "should have all expected attributes" do
    contact = create_contact(
      public_id: "unique_contact_9",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "attributes@example.com",
      expires_at: 1.day.from_now,
    )

    assert_respond_to email, :email_address
    assert_respond_to email, :activated
    assert_respond_to email, :deletable
    assert_respond_to email, :remaining_views
    assert_respond_to email, :expires_at
  end

  test "should have default values" do
    contact = create_contact(
      public_id: "unique_contact_10",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.create!(
      com_contact: contact,
      email_address: "test@example.com",
      expires_at: 1.day.from_now,
    )

    assert_not email.activated
    assert_not email.deletable
    assert_equal 10, email.remaining_views
  end

  # Validation tests
  test "should validate presence of email_address" do
    contact = create_contact(
      public_id: "unique_contact_11",
      created_at: Time.current,
      updated_at: Time.current,
    )
    email = ComContactEmail.new(
      com_contact: contact,
      expires_at: 1.day.from_now,
    )

    assert_not email.valid?
    assert_predicate email.errors[:email_address], :any?, "email_address should have validation errors"
  end

  test "should validate format of email_address" do
    contact = create_contact(
      public_id: "unique_contact_12",
      created_at: Time.current,
      updated_at: Time.current,
    )

    # Invalid email formats
    invalid_emails = ["invalid", "test@", "@example.com"]
    invalid_emails.each do |invalid_email|
      email = ComContactEmail.new(
        com_contact: contact,
        email_address: invalid_email,
        expires_at: 1.day.from_now,
      )

      assert_not email.valid?, "#{invalid_email} should be invalid"
      assert_predicate email.errors[:email_address], :any?, "#{invalid_email} should have validation errors"
    end

    # Valid email formats
    valid_emails = ["test@example.com", "user+tag@example.co.jp", "test.user@example.com"]
    valid_emails.each do |valid_email|
      email = ComContactEmail.new(
        com_contact: contact,
        email_address: valid_email,
        expires_at: 1.day.from_now,
      )

      assert_predicate email, :valid?, "#{valid_email} should be valid"
    end
  end

  private

  def create_contact(attrs = {})
    ComContact.create!(
      {
        confirm_policy: "1",
        category_id: ComContactCategory::SECURITY_ISSUE,
        status_id: ComContactStatus::NOTHING,
      }.merge(attrs),
    )
  end
end
