# == Schema Information
#
# Table name: com_contact_telephones
#
#  id                     :string           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  com_contact_id         :uuid             not null
#  created_at             :datetime         not null
#  deletable              :boolean          default(FALSE), not null
#  expires_at             :timestamptz      not null
#  hotp_counter           :integer          default(0), not null
#  hotp_secret            :string           default(""), not null
#  remaining_views        :integer          default(10), not null
#  telephone_number       :string(1000)     default(""), not null
#  updated_at             :datetime         not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id       (com_contact_id)
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
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )

    assert_respond_to telephone, :com_contact
    assert_not_nil telephone.com_contact
    assert_kind_of ComContact, telephone.com_contact
  end

  # Telephone numbers contain digits and symbols, so downcasing is not applicable
  # This test has been removed as the downcase behavior was removed from the model

  test "should encrypt telephone_number" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # Read directly from database to check encryption
    raw_value = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone.id}'"
    ).first["telephone_number"]

    # Encrypted value should be different from plaintext
    assert_not_equal "+1234567890", raw_value
    # But the model should decrypt it correctly
    assert_equal "+1234567890", telephone.reload.telephone_number
  end

  test "should support deterministic encryption for telephone_number" do
    contact = com_contacts(:one)

    # Create two records with the same telephone number
    telephone1 = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    telephone2 = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # With deterministic encryption, encrypted values should be the same
    raw1 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone1.id}'"
    ).first["telephone_number"]

    raw2 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = '#{telephone2.id}'"
    ).first["telephone_number"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    # Note: Encrypted fields in fixtures may cause issues
    # We create a fresh record instead of loading from fixtures
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )

    assert_predicate telephone, :valid?
  end

  test "should use Nanoid as primary key" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )

    assert_kind_of String, telephone.id
    assert_equal 21, telephone.id.length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should have timestamps" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+5555555555",
      expires_at: 1.day.from_now
    )

    assert_respond_to telephone, :created_at
    assert_respond_to telephone, :updated_at
    assert_not_nil telephone.created_at
    assert_not_nil telephone.updated_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should have all expected attributes" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+6666666666",
      expires_at: 1.day.from_now
    )

    assert_respond_to telephone, :telephone_number
    assert_respond_to telephone, :activated
    assert_respond_to telephone, :deletable
    assert_respond_to telephone, :remaining_views
    assert_respond_to telephone, :expires_at
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have default values" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    assert_not telephone.activated
    assert_not telephone.deletable
    assert_equal 10, telephone.remaining_views
  end

  # Validation tests
  test "should validate presence of telephone_number" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.new(
      com_contact: contact,
      expires_at: 1.day.from_now
    )

    assert_not telephone.valid?
    assert_predicate telephone.errors[:telephone_number], :any?, "telephone_number should have validation errors"
  end

  test "should validate format of telephone_number" do
    contact = com_contacts(:one)

    # Invalid telephone formats
    invalid_phones = [ "abc", "123-abc-4567", "!!!" ]
    invalid_phones.each do |invalid_phone|
      telephone = ComContactTelephone.new(
        com_contact: contact,
        telephone_number: invalid_phone,
        expires_at: 1.day.from_now
      )

      assert_not telephone.valid?, "#{invalid_phone} should be invalid"
      assert_predicate telephone.errors[:telephone_number], :any?, "#{invalid_phone} should have validation errors"
    end

    # Valid telephone formats
    valid_phones = [ "+1234567890", "123-456-7890", "(123) 456-7890", "+81 90 1234 5678" ]
    valid_phones.each do |valid_phone|
      telephone = ComContactTelephone.new(
        com_contact: contact,
        telephone_number: valid_phone,
        expires_at: 1.day.from_now
      )

      assert_predicate telephone, :valid?, "#{valid_phone} should be valid"
    end
  end

  # Alias attribute tests
  test "should alias otp_digest to verifier_digest" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    test_digest = "test_digest_value"
    telephone.otp_digest = test_digest

    assert_equal test_digest, telephone.verifier_digest
    assert_equal test_digest, telephone.otp_digest
  end

  test "should alias otp_expires_at to verifier_expires_at" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    test_time = 1.hour.from_now
    telephone.otp_expires_at = test_time

    assert_equal test_time.to_i, telephone.verifier_expires_at.to_i
    assert_equal test_time.to_i, telephone.otp_expires_at.to_i
  end

  test "should alias otp_attempts_left to verifier_attempts_left" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    test_attempts = 5
    telephone.otp_attempts_left = test_attempts

    assert_equal test_attempts, telephone.verifier_attempts_left
    assert_equal test_attempts, telephone.otp_attempts_left
  end

  # OTP tests
  # rubocop:disable Minitest/MultipleAssertions
  test "should generate OTP code" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    raw_otp = telephone.generate_otp!

    assert_not_nil raw_otp
    assert_equal 6, raw_otp.length
    assert_match(/\A\d{6}\z/, raw_otp)
    assert_not_nil telephone.otp_digest
    assert_not_nil telephone.otp_expires_at
    assert_equal 3, telephone.otp_attempts_left
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should verify correct OTP" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    raw_otp = telephone.generate_otp!

    assert telephone.verify_otp(raw_otp)
    assert telephone.reload.activated
    assert_equal 0, telephone.otp_attempts_left
  end

  test "should reject incorrect OTP and decrement attempts" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_otp!
    initial_attempts = telephone.otp_attempts_left

    assert_not telephone.verify_otp("000000")
    assert_not telephone.reload.activated
    assert_equal initial_attempts - 1, telephone.otp_attempts_left
  end

  test "should reject OTP when attempts exhausted" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    raw_otp = telephone.generate_otp!

    # Exhaust attempts
    telephone.update!(otp_attempts_left: 0)

    assert_not telephone.verify_otp(raw_otp)
    assert_not telephone.reload.activated
  end

  test "should reject expired OTP" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    raw_otp = telephone.generate_otp!

    # Expire the OTP
    telephone.update!(otp_expires_at: 1.hour.ago)

    assert_not telephone.verify_otp(raw_otp)
    assert_not telephone.reload.activated
  end

  test "otp_expired? should return true when expired" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_otp!

    assert_not telephone.otp_expired?

    telephone.update!(otp_expires_at: 1.hour.ago)

    assert_predicate telephone, :otp_expired?
  end

  test "can_resend_otp? should return true when OTP expired" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_otp!
    telephone.update!(otp_expires_at: 1.hour.ago)

    assert_predicate telephone, :can_resend_otp?
  end

  test "can_resend_otp? should return true when attempts exhausted" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_otp!
    telephone.update!(otp_attempts_left: 0)

    assert_predicate telephone, :can_resend_otp?
  end

  test "can_resend_otp? should return false when activated" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_otp!
    telephone.update!(activated: true)

    assert_not telephone.can_resend_otp?
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should generate and verify HOTP" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    code = telephone.generate_hotp!

    assert_not_nil telephone.hotp_secret
    assert_not_nil telephone.hotp_counter
    assert_equal 3, telephone.verifier_attempts_left
    assert_not telephone.activated

    # Verify with correct code
    assert telephone.verify_hotp_code(code)
    assert telephone.reload.activated
    assert_equal 0, telephone.verifier_attempts_left
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should reject invalid HOTP code" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    telephone.generate_hotp!
    initial_attempts = telephone.verifier_attempts_left

    assert_not telephone.verify_hotp_code("000000")
    assert_not telephone.reload.activated
    assert_equal initial_attempts - 1, telephone.verifier_attempts_left
  end

  test "should reject HOTP when attempts exhausted" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    code = telephone.generate_hotp!
    telephone.update!(verifier_attempts_left: 0)

    assert_not telephone.verify_hotp_code(code)
    assert_not telephone.reload.activated
  end

  test "should reject expired HOTP" do
    contact = com_contacts(:one)
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )

    code = telephone.generate_hotp!
    telephone.update!(verifier_expires_at: 1.minute.ago)

    assert_not telephone.verify_hotp_code(code)
    assert_not telephone.reload.activated
  end
end
