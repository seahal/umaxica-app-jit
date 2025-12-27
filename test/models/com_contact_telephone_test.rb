# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_telephones
#
#  id                     :string           not null, primary key
#  telephone_number       :string(1000)     default(""), not null
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  remaining_views        :integer          default(10), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#  verifier_attempts_left :integer          default(3), not null
#  expires_at             :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  com_contact_id         :uuid             not null
#  hotp_secret            :string           default(""), not null
#  hotp_counter           :integer          default(0), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id       (com_contact_id) UNIQUE
#  index_com_contact_telephones_on_expires_at           (expires_at)
#  index_com_contact_telephones_on_telephone_number     (telephone_number)
#  index_com_contact_telephones_on_verifier_expires_at  (verifier_expires_at)
#

require "test_helper"

class ComContactTelephoneTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert_operator ComContactTelephone, :<, GuestsRecord
  end

  test "should belong to com_contact" do
    contact = ComContact.create!(public_id: "phone_1", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551234567",
      activated: false,
      deletable: false,
      expires_at: 1.day.from_now,
    )

    assert_respond_to telephone, :com_contact
    assert_not_nil telephone.com_contact
    assert_kind_of ComContact, telephone.com_contact
  end

  # Telephone numbers contain digits and symbols, so downcasing is not applicable
  # This test has been removed as the downcase behavior was removed from the model

  test "should encrypt telephone_number" do
    contact = ComContact.create!(public_id: "phone_2", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551234568",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    # Read directly from database to check encryption
    raw_value = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone.id}'",
    ).first["telephone_number"]

    # Encrypted value should be different from plaintext
    assert_not_equal "+15551234568", raw_value
    # But the model should decrypt it correctly
    assert_equal "+15551234568", telephone.reload.telephone_number
  end

  test "should support deterministic encryption for telephone_number" do
    contact1 = ComContact.create!(public_id: "phone_3", created_at: Time.current, updated_at: Time.current)
    contact2 = ComContact.create!(public_id: "phone_4", created_at: Time.current, updated_at: Time.current)

    # Create two records with the same telephone number
    telephone1 = ComContactTelephone.create!(
      com_contact: contact1,
      telephone_number: "+15551234569",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    telephone2 = ComContactTelephone.create!(
      com_contact: contact2,
      telephone_number: "+15551234569",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now,
    )

    # With deterministic encryption, encrypted values should be the same
    raw1 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone1.id}'",
    ).first["telephone_number"]

    raw2 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone2.id}'",
    ).first["telephone_number"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    # Note: Encrypted fields in fixtures may cause issues
    # We create a fresh record instead of loading from fixtures
    contact = ComContact.create!(public_id: "phone_5", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000000",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now,
    )

    assert_predicate telephone, :valid?
  end

  test "should use Nanoid as primary key" do
    contact = ComContact.create!(public_id: "phone_6", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551111111",
      expires_at: 1.day.from_now,
    )

    assert_kind_of String, telephone.id

    assert_equal 21, telephone.id.length # Assuming standard nanoid length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = ComContact.create!(public_id: "phone_7", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15552222222",
      expires_at: 1.day.from_now,
    )

    assert_respond_to telephone, :created_at
    assert_respond_to telephone, :updated_at
    assert_not_nil telephone.created_at
    assert_not_nil telephone.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should have all expected attributes" do
    contact = ComContact.create!(public_id: "phone_8", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15553333333",
      expires_at: 1.day.from_now,
    )

    assert_respond_to telephone, :telephone_number
    assert_respond_to telephone, :activated
    assert_respond_to telephone, :deletable
    assert_respond_to telephone, :remaining_views
    assert_respond_to telephone, :expires_at
    assert_respond_to telephone, :hotp_secret
    assert_respond_to telephone, :hotp_counter
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have default values" do
    contact = ComContact.create!(public_id: "phone_9", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15554444444",
      expires_at: 1.day.from_now,
    )

    assert_not telephone.activated
    assert_not telephone.deletable
    assert_equal 10, telephone.remaining_views
    assert_not_nil telephone.hotp_secret
    assert_equal 0, telephone.hotp_counter
  end

  # Validation tests
  test "should validate presence of telephone_number" do
    contact = ComContact.create!(public_id: "phone_10", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.new(
      com_contact: contact,
      expires_at: 1.day.from_now,
    )

    assert_not telephone.valid?
    assert_predicate telephone.errors[:telephone_number], :any?, "telephone_number should have validation errors"
  end

  test "should validate format of telephone_number" do
    contact = ComContact.create!(public_id: "phone_10_1", created_at: Time.current, updated_at: Time.current)

    # Invalid telephone formats
    invalid_phones = ["abc", "123-abc-4567", "!!!"]
    invalid_phones.each do |invalid_phone|
      telephone = ComContactTelephone.new(
        com_contact: contact,
        telephone_number: invalid_phone,
        expires_at: 1.day.from_now,
      )

      assert_not telephone.valid?, "#{invalid_phone} should be invalid"
      assert_predicate telephone.errors[:telephone_number], :any?, "#{invalid_phone} should have validation errors"
    end

    # Valid telephone formats
    valid_phones = ["+1234567890", "123-456-7890", "(123) 456-7890", "+81 90 1234 5678"]
    valid_phones.each_with_index do |valid_phone, i|
      telephone = ComContactTelephone.new(
        com_contact: ComContact.create!(
          public_id: "phone_10_2_#{i}", created_at: Time.current,
          updated_at: Time.current,
        ),
        telephone_number: valid_phone,
        expires_at: 1.day.from_now,
      )

      assert_predicate telephone, :valid?, "#{valid_phone} should be valid"
    end
  end

  # Alias attribute tests
  test "should alias otp_digest to verifier_digest" do
    contact = ComContact.create!(public_id: "phone_11", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15555555555",
      expires_at: 1.day.from_now,
    )

    # Generate OTP (which sets verifier_digest)
    telephone.generate_otp!

    assert_not_nil telephone.verifier_digest
    assert_equal telephone.otp_digest, telephone.verifier_digest
  end

  test "should alias otp_expires_at to verifier_expires_at" do
    contact = ComContact.create!(public_id: "phone_12", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15556666666",
      expires_at: 1.day.from_now,
    )

    # Generate OTP
    telephone.generate_otp!

    assert_not_nil telephone.verifier_expires_at
    assert_equal telephone.otp_expires_at, telephone.verifier_expires_at
  end

  test "should alias otp_attempts_left to verifier_attempts_left" do
    contact = ComContact.create!(public_id: "phone_13", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15557777777",
      expires_at: 1.day.from_now,
    )

    assert_not_nil telephone.verifier_attempts_left
    assert_equal telephone.otp_attempts_left, telephone.verifier_attempts_left
  end

  # OTP tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should generate OTP" do
    contact = ComContact.create!(public_id: "phone_14", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15558888888",
      expires_at: 1.day.from_now,
    )

    raw_code = telephone.generate_otp!

    assert_not_nil raw_code
    assert_equal 6, raw_code.length
    assert_match(/\A\d{6}\z/, raw_code)
    assert_not_nil telephone.otp_digest
    assert_not_nil telephone.otp_expires_at
    assert_equal 3, telephone.otp_attempts_left
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should verify correct OTP" do
    contact = ComContact.create!(public_id: "phone_15", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15559999999",
      expires_at: 1.day.from_now,
    )

    raw_code = telephone.generate_otp!

    assert telephone.verify_otp(raw_code)
    assert telephone.reload.activated
    assert_equal 0, telephone.otp_attempts_left
  end

  test "should reject incorrect OTP_and decrement attempts" do
    contact = ComContact.create!(public_id: "phone_16", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000001",
      expires_at: 1.day.from_now,
    )

    telephone.generate_otp!
    initial_attempts = telephone.otp_attempts_left

    assert_not telephone.verify_otp("000000")
    assert_not telephone.reload.activated
    assert_equal initial_attempts - 1, telephone.otp_attempts_left
  end

  test "should reject OTP_when attempts exhausted" do
    contact = ComContact.create!(public_id: "phone_17", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000002",
      expires_at: 1.day.from_now,
    )

    raw_code = telephone.generate_otp!

    # Exhaust attempts
    telephone.update!(verifier_attempts_left: 0)

    assert_not telephone.verify_otp(raw_code)
    assert_not telephone.reload.activated
  end

  test "should reject expired OTP" do
    contact = ComContact.create!(public_id: "phone_18", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000003",
      expires_at: 1.day.from_now,
    )

    raw_code = telephone.generate_otp!

    # Expire the code
    telephone.update!(verifier_expires_at: 1.hour.ago)

    assert_not telephone.verify_otp(raw_code)
    assert_not telephone.reload.activated
  end

  test "otp_expired? should return true when expired" do
    contact = ComContact.create!(public_id: "phone_19", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000004",
      expires_at: 1.day.from_now,
    )

    telephone.generate_otp!

    assert_not telephone.otp_expired?

    telephone.update!(verifier_expires_at: 1.hour.ago)

    assert_predicate telephone, :otp_expired?
  end

  test "can_resend_otp? should return true when OTP_expired" do
    contact = ComContact.create!(public_id: "phone_20", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000005",
      expires_at: 1.day.from_now,
    )

    telephone.generate_otp!
    telephone.update!(verifier_expires_at: 1.hour.ago)

    assert_predicate telephone, :can_resend_otp?
  end

  test "can_resend_otp? should return true when attempts exhausted" do
    contact = ComContact.create!(public_id: "phone_21", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000006",
      expires_at: 1.day.from_now,
    )

    telephone.generate_otp!
    telephone.update!(verifier_attempts_left: 0)

    assert_predicate telephone, :can_resend_otp?
  end

  test "can_resend_otp? should return false when activated" do
    contact = ComContact.create!(public_id: "phone_22", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000007",
      expires_at: 1.day.from_now,
    )

    telephone.generate_otp!
    telephone.update!(activated: true)

    assert_not telephone.can_resend_otp?
  end

  # HOTP tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should generate and verify HOTP" do
    contact = ComContact.create!(public_id: "phone_23", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000008",
      expires_at: 1.day.from_now,
    )

    # Initial state
    initial_counter = telephone.hotp_counter

    # Generate HOTP
    code1 = telephone.generate_hotp!
    telephone.reload

    # Counter should have changed (randomly generated)
    assert_not_equal initial_counter, telephone.hotp_counter
    counter1 = telephone.hotp_counter

    # Verify
    assert telephone.verify_hotp_code(code1)

    # Counter does not increment on verification in this implementation
    assert_equal counter1, telephone.reload.hotp_counter

    # Generate next code
    code2 = telephone.generate_hotp!
    telephone.reload

    assert_not_equal code1, code2
    assert_not_equal counter1, telephone.hotp_counter

    assert telephone.verify_hotp_code(code2)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should reject reuse of HOTP code" do
    contact = ComContact.create!(public_id: "phone_24", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000009",
      expires_at: 1.day.from_now,
    )

    code = telephone.generate_hotp!

    assert telephone.verify_hotp_code(code)
    assert_not telephone.verify_hotp_code(code)
  end

  test "should reject incorrect HOTP" do
    contact = ComContact.create!(public_id: "phone_25", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000010",
      expires_at: 1.day.from_now,
    )

    telephone.generate_hotp!
    initial_counter = telephone.hotp_counter

    assert_not telephone.verify_hotp_code("000000")
    assert_equal initial_counter, telephone.reload.hotp_counter
  end

  test "should reject expired HOTP" do
    contact = ComContact.create!(public_id: "phone_26", created_at: Time.current, updated_at: Time.current)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000011",
      expires_at: 1.day.from_now,
    )

    code = telephone.generate_hotp!

    # Correct.
    telephone.update!(verifier_expires_at: 1.hour.ago)
    assert_not telephone.verify_hotp_code(code)
  end
end
