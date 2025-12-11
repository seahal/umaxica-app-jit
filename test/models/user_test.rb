# == Schema Information
#
# Table name: users
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid" do
    assert_predicate @user, :valid?
  end

  test "should have timestamps" do
    assert_not_nil @user.created_at
    assert_not_nil @user.updated_at
  end

  test "should have one user_identity_apple_auth association" do
    assert_respond_to @user, :user_identity_apple_auth
    assert_equal :has_one, @user.class.reflect_on_association(:user_identity_apple_auth).macro
  end

  test "should have one user_identity_google_auth association" do
    assert_respond_to @user, :user_identity_google_auth
    assert_equal :has_one, @user.class.reflect_on_association(:user_identity_google_auth).macro
  end

  test "should have many user_webauthn_credentials association" do
    assert_respond_to @user, :user_webauthn_credentials
    assert_equal :has_many, @user.class.reflect_on_association(:user_webauthn_credentials).macro
  end

  test "staff? should return false" do
    assert_not @user.staff?
  end

  test "user? should return true" do
    assert_predicate @user, :user?
  end
end
