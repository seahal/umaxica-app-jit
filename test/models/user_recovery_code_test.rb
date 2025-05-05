# == Schema Information
#
# Table name: user_recovery_codes
#
#  id              :bigint           not null, primary key
#  expire_in       :date
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
