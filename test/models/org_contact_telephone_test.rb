# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_telephones
#
#  id                     :string           not null, primary key
#  org_contact_id         :uuid             not null
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
#  index_org_contact_telephones_on_expires_at           (expires_at)
#  index_org_contact_telephones_on_org_contact_id       (org_contact_id)
#  index_org_contact_telephones_on_telephone_number     (telephone_number)
#  index_org_contact_telephones_on_verifier_expires_at  (verifier_expires_at)
#

require "test_helper"

class OrgContactTelephoneTest < ActiveSupport::TestCase
  def setup
    @org_contact = OrgContact.find_by!(public_id: "test_org_contact_0001")
    @telephone = OrgContactTelephone.new(
      org_contact: @org_contact,
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
  end

  test "verify_otp should decrement attempts on wrong code" do
    @telephone.generate_otp!

    assert_not @telephone.verify_otp("111111")
    assert_equal 2, @telephone.reload.otp_attempts_left
  end

  test "verify_otp should fail when no attempts left" do
    @telephone.generate_otp!
    @telephone.update!(otp_attempts_left: 0)

    assert_not @telephone.verify_otp("111111")
  end

  test "verify_otp should fail when code expired" do
    freeze_time do
      raw_otp = @telephone.generate_otp!
      travel 11.minutes

      assert_not @telephone.verify_otp(raw_otp)
      assert_not @telephone.reload.activated
    end
  end

  test "otp_expired? reflects expiration timestamp" do
    assert_predicate @telephone, :otp_expired?

    freeze_time do
      @telephone.update!(otp_expires_at: 5.minutes.from_now)

      assert_not @telephone.otp_expired?

      travel 6.minutes

      assert_predicate @telephone, :otp_expired?
    end
  end

  test "can_resend_otp? returns false when not expired and has attempts" do
    @telephone.assign_attributes(activated: false, otp_attempts_left: 3, otp_expires_at: 5.minutes.from_now)

    assert_not @telephone.can_resend_otp?
  end

  test "can_resend_otp? returns true when no attempts left" do
    @telephone.assign_attributes(activated: false, otp_attempts_left: 0, otp_expires_at: 5.minutes.from_now)

    assert_predicate @telephone, :can_resend_otp?
  end

  test "can_resend_otp? returns true when code expired" do
    @telephone.assign_attributes(activated: false, otp_attempts_left: 2, otp_expires_at: 1.minute.ago)

    assert_predicate @telephone, :can_resend_otp?
  end

  test "can_resend_otp? returns false when already activated" do
    @telephone.assign_attributes(activated: true, otp_attempts_left: 0, otp_expires_at: 1.minute.ago)

    assert_not @telephone.can_resend_otp?
  end
end
