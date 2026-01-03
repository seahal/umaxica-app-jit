# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_telephones
#
#  id                     :string           not null, primary key
#  app_contact_id         :uuid             not null
#  telephone_number       :string(1000)     default(""), not null
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  remaining_views        :integer          default(0), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#  verifier_attempts_left :integer          default(0), not null
#  expires_at             :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_app_contact_telephones_on_app_contact_id       (app_contact_id)
#  index_app_contact_telephones_on_expires_at           (expires_at)
#  index_app_contact_telephones_on_telephone_number     (telephone_number)
#  index_app_contact_telephones_on_verifier_expires_at  (verifier_expires_at)
#

require "test_helper"

class AppContactTelephoneTest < ActiveSupport::TestCase
  def setup
    @app_contact = AppContact.find_by!(public_id: "one_app_contact_00001")
    @telephone = AppContactTelephone.new(
      app_contact: @app_contact,
      telephone_number: "+819012345678",
    )
  end

  test "should be valid" do
    assert_predicate @telephone, :valid?
  end

  test "should require telephone_number" do
    @telephone.telephone_number = nil

    assert_not @telephone.valid?
  end

  test "should validate telephone format" do
    valid_numbers = %w(+12125551234 090-1234-5678 1234567890)
    valid_numbers.each do |num|
      @telephone.telephone_number = num

      assert_predicate @telephone, :valid?, "#{num.inspect} should be valid"
    end
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "generate_otp! should create a code and set expiration" do
    freeze_time do
      raw_otp = @telephone.generate_otp!

      assert_not_nil @telephone.otp_digest
      assert_equal 6, raw_otp.length
      assert_equal 10.minutes.from_now, @telephone.otp_expires_at
      assert_equal 3, @telephone.otp_attempts_left
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "verify_otp should return true for correct code" do
    raw_otp = @telephone.generate_otp!

    assert @telephone.verify_otp(raw_otp)
    assert @telephone.reload.activated
    assert_equal 0, @telephone.otp_attempts_left
  end

  test "verify_otp should return false for incorrect code" do
    @telephone.generate_otp!

    assert_not @telephone.verify_otp("000000")
    assert_not @telephone.activated
    assert_equal 2, @telephone.otp_attempts_left
  end

  test "can_resend_otp? logic" do
    assert_predicate @telephone, :can_resend_otp?
    @telephone.generate_otp!

    assert_not @telephone.can_resend_otp?

    travel 11.minutes do
      assert_predicate @telephone, :can_resend_otp?
    end
  end
end
