# == Schema Information
#
# Table name: user_recovery_codes
#
#  id              :uuid             not null, primary key
#  expires_in      :date
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class UserRecoveryCodeTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
