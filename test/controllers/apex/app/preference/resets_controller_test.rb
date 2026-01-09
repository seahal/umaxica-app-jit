# frozen_string_literal: true

require "test_helper"
require "rack/utils"
require "uri"

class Apex::App::Preference::ResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_SERVICE_URL", "app.localhost")
    https!

    @preference = app_preferences(:one)

    # Set the cookie
    @token = SecureRandom.urlsafe_base64(48)
    token_digest = SHA3::Digest::SHA3_384.digest(@token)
    @preference.update!(token_digest: token_digest)
  end

  test "should redirect after reset" do
    perform_reset

    assert_response :redirect
    assert_match edit_apex_app_preference_reset_path, response.location
  end

  test "should delete preference cookie after reset" do
    perform_reset

    cookie_name = preference_cookie_name
    assert_includes [nil, ""], cookies[cookie_name]
    assert_match(/#{cookie_name}=;/, normalized_set_cookie_header)
    assert_match(/expires=Thu, 01 Jan 1970 00:00:00 GMT/, normalized_set_cookie_header)
  end

  test "should audit and delete preference after reset" do
    initial_count = AppPreferenceAudit.count

    perform_reset

    assert_equal 1, AppPreferenceAudit.count - initial_count
    audit = AppPreferenceAudit.order(:created_at).last
    assert_equal "RESET_BY_USER_DECISION", audit.event_id
    assert_equal "INFO", audit.level_id

    @preference.reload
    assert_equal "DELETED", @preference.status_id
  end

  test "should get edit" do
    get edit_apex_app_preference_reset_url, headers: { "Cookie" => "#{preference_cookie_name}=#{@token}" }

    assert_response :success
    assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
    assert_select "input[type='submit'][data-turbo-confirm]"
  end

  private

  def perform_reset
    delete apex_app_preference_reset_url, headers: { "Cookie" => "#{preference_cookie_name}=#{@token}" }
  end

  def preference_cookie_name
    Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
  end

  def normalized_set_cookie_header
    header = response.headers["Set-Cookie"]
    header.is_a?(Array) ? header.join("\n") : header
  end
end
