# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "backward compatibility: old mfa path redirects to challenge" do
    get "http://#{ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")}/in/mfa"
    assert_response :found
    assert_redirected_to "http://#{ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")}/in/challenge"
  end
end
