require "test_helper"

class StaffIdentitySecretTest < ActiveSupport::TestCase
  setup do
    @staff = staffs(:one)
  end

  test "allows up to the maximum number of secrets per staff" do
    StaffIdentitySecret::MAX_SECRETS_PER_STAFF.times do
      create_secret!
    end

    assert_equal StaffIdentitySecret::MAX_SECRETS_PER_STAFF,
                 StaffIdentitySecret.where(staff: @staff).count
  end

  test "rejects creating more than the maximum secrets per staff" do
    StaffIdentitySecret::MAX_SECRETS_PER_STAFF.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  private

  def create_secret!
    StaffIdentitySecret.create!(
      staff: @staff,
      password: "SecurePass123!",
      password_confirmation: "SecurePass123!"
    )
  end
end
