# == Schema Information
#
# Table name: staff_one_time_passwords
# Database name: operator
#
#  id                                :bigint           not null, primary key
#  secret_key                        :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  public_id                         :string(21)       not null
#  staff_id                          :bigint           not null
#  staff_one_time_password_status_id :bigint           default(4), not null
#
# Indexes
#
#  idx_staff_otps_on_staff_id                   (staff_id)
#  idx_staff_otps_on_status_id                  (staff_one_time_password_status_id)
#  index_staff_one_time_passwords_on_public_id  (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...                                                     (staff_id => staffs.id) ON DELETE => cascade
#  fk_staff_one_time_passwords_on_staff_one_time_password_status_i
#    (staff_one_time_password_status_id => staff_one_time_password_statuses.id)
#

# frozen_string_literal: true

require "test_helper"

class StaffOneTimePasswordTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_one_time_password_statuses

  test "generates private_key and public_id when blank" do
    staff = staffs(:one)
    totp = StaffOneTimePassword.new(
      staff: staff,
      private_key: "",
      public_id: nil,
    )

    totp.valid?

    assert_predicate totp.private_key, :present?
    assert_equal 21, totp.public_id.to_s.length
  end

  test "enforces per-staff totp limit on create" do
    staff = staffs(:two)

    StaffOneTimePassword::MAX_TOTPS_PER_STAFF.times do |index|
      StaffOneTimePassword.create!(
        staff: staff,
        private_key: "key-#{index}",
      )
    end

    extra = StaffOneTimePassword.new(
      staff: staff,
      private_key: "extra-key",
    )

    assert_not extra.valid?
    message = "exceeds maximum totps per staff (#{StaffOneTimePassword::MAX_TOTPS_PER_STAFF})"
    assert_includes extra.errors[:base], message
  end
end
