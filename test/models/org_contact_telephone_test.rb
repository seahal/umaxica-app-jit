require "test_helper"

class OrgContactTelephoneTest < ActiveSupport::TestCase
  def setup
    @org_contact = org_contacts(:one)
    @telephone = OrgContactTelephone.new(
      org_contact: @org_contact,
      telephone_number: "+819012345678"
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
end
