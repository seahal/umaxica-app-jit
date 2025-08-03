# frozen_string_literal: true

# == Schema Information
#
# Table name: user_apple_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_apple_auths_on_user_id  (user_id)
#
require "test_helper"

class UserAppleAuthTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user_apple_auth = UserAppleAuth.new(token: "sample_token")
    # Don't validate user_id association since we don't have fixtures for it
    assert_nothing_raised do
      user_apple_auth.save(validate: false)
    end
  end

  test "should belong to user" do
    assert_respond_to UserAppleAuth.new, :user
  end

  test "should have required fields" do
    user_apple_auth = UserAppleAuth.new
    assert_includes UserAppleAuth.column_names, "token"
    assert_includes UserAppleAuth.column_names, "user_id"
  end

  test "should inherit from IdentifiersRecord" do
    assert UserAppleAuth.ancestors.include?(IdentifiersRecord)
  end
end
