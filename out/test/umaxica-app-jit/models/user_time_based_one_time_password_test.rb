# == Schema Information
#
# Table name: user_time_based_one_time_passwords
#
#  time_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
require "test_helper"

class UserTimeBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
