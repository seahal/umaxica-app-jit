# == Schema Information
#
# Table name: staff_identity_secrets
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  expires_at                      :datetime         default("infinity"), not null
#  last_used_at                    :datetime         default("-infinity"), not null
#  name                            :string           default(""), not null
#  password_digest                 :string           default(""), not null
#  staff_id                        :uuid             not null
#  staff_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  idx_on_staff_identity_secret_status_id_0999b0c4ae  (staff_identity_secret_status_id)
#  index_staff_identity_secrets_on_expires_at         (expires_at)
#  index_staff_identity_secrets_on_staff_id           (staff_id)
#

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
        name: "Secret-#{SecureRandom.hex(4)}",
        password: "SecurePass123!",
        password_confirmation: "SecurePass123!"
      )
    end
end
