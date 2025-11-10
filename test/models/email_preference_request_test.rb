# frozen_string_literal: true

require "test_helper"

class EmailPreferenceRequestTest < ActiveSupport::TestCase
  test "defaults optional preferences" do
    request = EmailPreferenceRequest.create!(email_address: "user@example.com", context: :app)

    assert_equal true, request.preferences_with_defaults[:product_updates]
    assert_equal true, request.preferences_with_defaults[:promotional_messages]
  end

  test "find_by_token scopes by context" do
    request = EmailPreferenceRequest.create!(email_address: "staff@example.com", context: :org)

    found = EmailPreferenceRequest.find_by_token(:org, request.raw_token)
    assert_equal request, found
    assert_nil EmailPreferenceRequest.find_by_token(:app, request.raw_token)
  end

  test "mark_preferences! normalizes and marks token used" do
    request = EmailPreferenceRequest.create!(email_address: "user@example.com", context: :app)

    request.mark_preferences!(product_updates: "0", promotional_messages: "1")

    assert_equal false, request.preferences["product_updates"]
    assert_equal true, request.preferences["promotional_messages"]
    assert_not_nil request.token_used_at
  end

  test "token_valid? is false after expiry or use" do
    request = EmailPreferenceRequest.create!(email_address: "user@example.com", context: :app)

    assert request.token_valid?

    request.update!(token_used_at: 1.minute.ago)
    assert_not request.reload.token_valid?

    request.update!(token_used_at: nil)
    request.update!(token_expires_at: 1.minute.ago)
    assert_not request.reload.token_valid?
  end
end
