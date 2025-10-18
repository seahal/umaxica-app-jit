# == Schema Information
#
# Table name: staff_hmac_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  staff_id                        :binary           not null
#
require "test_helper"

class StaffHmacBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
