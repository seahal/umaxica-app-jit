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

  test "should have many emails association" do
    assert_respond_to @user, :emails
    assert_equal "user_id", @user.class.reflect_on_association(:user_emails).foreign_key
  end

  test "should have many phones association" do
    assert_respond_to @user, :phones
    assert_equal "user_id", @user.class.reflect_on_association(:user_telephones).foreign_key
  end

  test "should have one user_apple_auth association" do
    assert_respond_to @user, :user_apple_auth
    assert_equal :has_one, @user.class.reflect_on_association(:user_apple_auth).macro
  end

  test "should have one user_google_auth association" do
    assert_respond_to @user, :user_google_auth
    assert_equal :has_one, @user.class.reflect_on_association(:user_google_auth).macro
  end

  test "should have many user_sessions association" do
    assert_respond_to @user, :user_sessions
    assert_equal :has_many, @user.class.reflect_on_association(:user_sessions).macro
  end

  test "should have many user_time_based_one_time_password association" do
    assert_respond_to @user, :user_time_based_one_time_password
    assert_equal :has_many, @user.class.reflect_on_association(:user_time_based_one_time_password).macro
  end
end
