# == Schema Information
#
# Table name: user_identity_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
require "test_helper"

class UserIdentityOneTimePasswordTest < ActiveSupport::TestCase
  test "inherits from IdentitiesRecord" do
    assert_operator UserIdentityOneTimePassword, :<, IdentitiesRecord
  end

  test "belongs to user" do
    association = UserIdentityOneTimePassword.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to hmac_based_one_time_password" do
    association = UserIdentityOneTimePassword.reflect_on_association(:hmac_based_one_time_password)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  # test "loads user and hmac associations from fixtures" do
  #   record = user_identity_one_time_passwords(:one)

  #   assert_equal users(:one), record.user
  #   assert_equal hmac_based_one_time_passwords(:one), record.hmac_based_one_time_password
  # end

  test "allows assignment of associations before persistence" do
    user = users(:one)
    hmac = hmac_based_one_time_passwords(:one)

    record = UserIdentityOneTimePassword.new(user:, hmac_based_one_time_password: hmac)

    assert_same user, record.user
    assert_same hmac, record.hmac_based_one_time_password
  end
end
