# == Schema Information
#
# Table name: user_time_based_one_time_passwords
#
#  time_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
require "test_helper"

class UserTimeBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "inherits from IdentitiesRecord" do
    assert_operator UserTimeBasedOneTimePassword, :<, IdentitiesRecord
  end

  test "belongs to user" do
    association = UserTimeBasedOneTimePassword.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "assigns user association without persistence" do
    user = User.new
    record = UserTimeBasedOneTimePassword.new(user:)

    assert_same user, record.user
  end
end
