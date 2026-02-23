# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "backward compatibility: old mfa path redirects to challenge" do
    get "http://#{ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")}/configuration/mfa"
    assert_response :found
    assert_redirected_to "http://#{ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")}/configuration/challenge"
  end
end
