# == Schema Information
#
# Table name: staff_recovery_codes
#
#  id                   :uuid             not null, primary key
#  expires_in           :date
#  recovery_code_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  staff_id             :bigint           not null
#
# Indexes
#
#  index_staff_recovery_codes_on_staff_id  (staff_id)
#
require "test_helper"

class StaffRecoveryCodeTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
