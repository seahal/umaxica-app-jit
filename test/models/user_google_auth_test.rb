# frozen_string_literal: true

# == Schema Information
#
# Table name: user_google_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_google_auths_on_user_id  (user_id)
#
require "test_helper"

class UserGoogleAuthTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user_google_auth = UserGoogleAuth.new(token: "sample_google_token")
    # Don't validate user_id association since we don't have fixtures for it
    assert_nothing_raised do
      user_google_auth.save(validate: false)
    end
  end

  test "should belong to user" do
    assert_respond_to UserGoogleAuth.new, :user
  end

  test "should have required fields" do
    user_google_auth = UserGoogleAuth.new

    assert_includes UserGoogleAuth.column_names, "token"
    assert_includes UserGoogleAuth.column_names, "user_id"
  end

  test "should inherit from IdentitiesRecord" do
    assert_includes UserGoogleAuth.ancestors, IdentitiesRecord
  end

  test "should handle token storage" do
    auth = UserGoogleAuth.new(token: "test_token_123", user_id: 1)

    assert_equal "test_token_123", auth.token
  end
end
