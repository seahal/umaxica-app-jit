# == Schema Information
#
# Table name: staff_one_time_passwords
# Database name: operator
#
#  id                                :uuid             not null, primary key
#  last_otp_at                       :datetime         default(-Infinity), not null
#  private_key                       :string(1024)     default(""), not null
#  title                             :string(32)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  public_id                         :string(21)
#  staff_id                          :uuid             not null
#  staff_one_time_password_status_id :string           default("NEYO"), not null
#
# Indexes
#
#  idx_on_staff_one_time_password_status_id_8958a1c9bf  (staff_one_time_password_status_id)
#  index_staff_one_time_passwords_on_public_id          (public_id) UNIQUE
#  index_staff_one_time_passwords_on_staff_id           (staff_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_one_time_password_status_id => staff_one_time_password_statuses.id)
#

# frozen_string_literal: true

require "test_helper"

class StaffOneTimePasswordTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_one_time_password_statuses

  test "generates private_key and public_id when blank" do
    staff = staffs(:one)
    totp = StaffOneTimePassword.new(
      staff: staff,
      last_otp_at: Time.current,
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
        last_otp_at: Time.current,
        private_key: "key-#{index}",
      )
    end

    extra = StaffOneTimePassword.new(
      staff: staff,
      last_otp_at: Time.current,
      private_key: "extra-key",
    )

    assert_not extra.valid?
    assert_includes extra.errors[:base], "exceeds maximum totps per staff (#{StaffOneTimePassword::MAX_TOTPS_PER_STAFF})"
  end
end
