# typed: false
# frozen_string_literal: true

require "test_helper"

class TokenRecordTest < ActiveSupport::TestCase
  fixtures :user_tokens, :users, :user_token_kinds, :user_token_statuses

  test "should be abstract class" do
    assert_predicate TokenRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator TokenRecord, :<, ApplicationRecord
  end

  test "should connect to token database" do
    # Test that the model is configured to use the token database
    # Note: This is a basic structural test
    assert_respond_to TokenRecord, :connection_db_config
  end

  test "as_json excludes sensitive refresh token fields by default" do
    token = user_tokens(:one)

    payload = token.as_json

    assert_not payload.key?("refresh_token_digest")
    assert_not payload.key?("refresh_token_family_id")
    assert_not payload.key?("refresh_token_generation")
    assert_not payload.key?("id")
    assert_equal token.public_id, payload["public_id"]
  end

  test "as_json merges except options" do
    token = user_tokens(:one)

    payload = token.as_json(except: [:public_id])

    assert_not payload.key?("public_id")
    assert_not payload.key?("refresh_token_digest")
  end
end
