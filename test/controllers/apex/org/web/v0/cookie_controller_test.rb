# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::Org::Web::V0::CookieControllerTest < ActionDispatch::IntegrationTest
  include PreferenceJwtHelper

  setup do
    @host = ENV.fetch("APEX_STAFF_URL", "org.localhost")
    host! @host
  end

  test "GET show returns show_banner false when consent is true" do
    token = encode_preference_jwt(
      preferences: { "consent" => true },
      host: @host,
      public_id: "pref-org-public-id",
      preference_type: "OrgPreference",
    )
    cookies[Preference::CookieName.access] = token

    with_preference_jwt_keys(host: @host) do
      get apex_org_web_v0_cookie_path, as: :json
    end

    assert_response :ok
    assert_not response.parsed_body["show_banner"]
  end

  test "PATCH update returns 200 and sets preference_consented cookie with org domain" do
    token = encode_preference_jwt(
      preferences: { "consented" => true },
      host: @host,
      public_id: "pref-org-public-id",
      preference_type: "OrgPreference",
    )
    cookies[Preference::CookieName.access] = token
    expires_at = Time.utc(2032, 3, 4, 5, 6, 7)

    with_cookie_domain_credentials(COOKIE_DOMAIN_ORG: ".org.example.test") do
      with_preference_jwt_keys(host: @host) do
        Apex::Org::Web::V0::CookiesController.any_instance.stub(:refresh_token_expires_at, expires_at) do
          patch apex_org_web_v0_cookie_path, as: :json
        end
      end
    end

    assert_response :ok
    assert_not response.parsed_body["show_banner"], "consented=true means banner should not show"
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "preference_consented=1"
    assert_includes set_cookie, "domain=.org.example.test"
    assert_includes set_cookie.downcase, "path=/"
    expires = response_cookie_expiry("preference_consented")

    assert_not_nil expires
    assert_in_delta expires_at.to_i, expires.to_i, 1
  end

  test "PATCH update with consented true updates org preference cookie and issues access token" do
    preference = OrgPreference.create!(status_id: OrgPreferenceStatus::NOTHING)
    OrgPreferenceCookie.create!(
      preference: preference,
      targetable: false,
      performant: false,
      functional: false,
      consented: false,
      consented_at: nil,
    )
    token = encode_preference_jwt(
      preferences: { "consented" => false, "consent" => nil },
      host: @host,
      public_id: preference.public_id,
      preference_type: "OrgPreference",
    )
    cookies[Preference::CookieName.access] = token

    with_preference_jwt_keys(host: @host) do
      patch apex_org_web_v0_cookie_path, params: { consented: true }, as: :json
    end

    assert_response :ok
    preference.reload

    assert preference.org_preference_cookie.consented
    assert_not_nil preference.org_preference_cookie.consented_at
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "preference_consented="
    assert_includes set_cookie, "#{Preference::CookieName.access}="
  end

  private

  def with_cookie_domain_credentials(overrides)
    creds = Rails.app.creds
    fetch = ->(key, default: nil) { overrides.fetch(key, default) }

    creds.stub(:option, fetch) do
      yield
    end
  end
end
