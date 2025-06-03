# == Schema Information
#
# Table name: users
#
#  id         :binary           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid" do
    assert @user.valid?
  end

  # test "should inherit from IdentifiersRecord" do
  #   assert_instance_of IdentifiersRecord, @user
  #   assert_kind_of IdentifiersRecord, @user
  # end

  test "should have binary id" do
    assert @user.id.is_a?(String)
    assert @user.id.encoding == Encoding::ASCII_8BIT
  end

  test "should have timestamps" do
    assert_not_nil @user.created_at
    assert_not_nil @user.updated_at
  end

  test "should have many emails association" do
    assert_respond_to @user, :emails
    assert_equal "address", @user.class.reflect_on_association(:emails).foreign_key
  end

  test "should have many phones association" do
    assert_respond_to @user, :phones
    assert_equal "id", @user.class.reflect_on_association(:phones).foreign_key
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

  # test "should create user with valid attributes" do
  #   user = User.new
  #   assert user.save
  #   assert_not_nil user.id
  #   assert_not_nil user.created_at
  #   assert_not_nil user.updated_at
  # end

  test "should update timestamps on save" do
    original_updated_at = @user.updated_at
    travel 1.second do
      @user.touch
      assert @user.updated_at > original_updated_at
    end
  end
end
