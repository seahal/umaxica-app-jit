# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::Org::Web::V0::CookieControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_STAFF_URL", "org.localhost")
  end

  test "GET show returns show_banner false when consent is true" do
    controller = Apex::Org::Web::V0::CookiesController
    cookies[Preference::CookieName.access] = "dummy.preference.token"
    controller.any_instance.stub(:decode_and_verify_preference_jwt, { "preferences" => { "consent" => true } }) do
      get apex_org_web_v0_cookie_path, as: :json
    end

    assert_response :ok
    assert_not response.parsed_body["show_banner"]
  end

  test "PATCH update returns 200 and sets jit_preference_consented cookie with org domain" do
    controller = Apex::Org::Web::V0::CookiesController
    expires_at = Time.utc(2032, 3, 4, 5, 6, 7)

    with_env("COOKIE_DOMAIN_ORG", ".org.example.test") do
      controller.any_instance.stub(
        :decode_and_verify_preference_jwt,
        { "preferences" => { "consented" => true }, "public_id" => "pref-org-public-id" },
      ) do
        controller.any_instance.stub(:refresh_token_expires_at, expires_at) do
          patch apex_org_web_v0_cookie_path, as: :json
        end
      end
    end

    assert_response :ok
    assert response.parsed_body["show_banner"]
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "jit_preference_consented=1"
    assert_includes set_cookie, "domain=.org.example.test"
    assert_includes set_cookie.downcase, "path=/"
    expires = response_cookie_expiry("jit_preference_consented")

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
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller = Apex::Org::Web::V0::CookiesController
    controller.any_instance.stub(
      :decode_and_verify_preference_jwt,
      { "preferences" => { "consented" => false, "consent" => nil }, "public_id" => preference.public_id },
    ) do
      patch apex_org_web_v0_cookie_path, params: { consented: true }, as: :json
    end

    assert_response :ok
    preference.reload

    assert preference.org_preference_cookie.consented
    assert_not_nil preference.org_preference_cookie.consented_at
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "jit_preference_consented="
    assert_includes set_cookie, "#{Preference::CookieName.access}="
  end

  private

  def with_env(key, value)
    previous = ENV[key]
    ENV[key] = value
    yield
  ensure
    ENV[key] = previous
  end
end
