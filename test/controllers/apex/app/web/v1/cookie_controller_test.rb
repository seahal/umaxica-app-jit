# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::App::Web::V1::CookieControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_SERVICE_URL", "app.localhost")
  end

  test "GET show without access jwt returns show_banner true" do
    cookies.delete(Preference::CookieName.access)

    get apex_app_web_v1_cookie_path, as: :json

    assert_response :ok
    assert response.parsed_body["show_banner"]
  end

  test "GET show returns show_banner true when jwt decode fails" do
    controller = Apex::App::Web::V1::CookiesController
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller.any_instance.stub(:decode_and_verify_preference_jwt, ->(_) { raise JWT::DecodeError, "invalid" }) do
      get apex_app_web_v1_cookie_path, as: :json
    end

    assert_response :ok
    assert response.parsed_body["show_banner"]
  end

  test "GET show returns show_banner false when consent is true" do
    controller = Apex::App::Web::V1::CookiesController
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller.any_instance.stub(:decode_and_verify_preference_jwt, { "preferences" => { "consent" => true } }) do
      get apex_app_web_v1_cookie_path, as: :json
    end

    assert_response :ok
    assert_not response.parsed_body["show_banner"]
  end

  test "GET show returns show_banner true when consent is false" do
    controller = Apex::App::Web::V1::CookiesController
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller.any_instance.stub(:decode_and_verify_preference_jwt, { "preferences" => { "consent" => false } }) do
      get apex_app_web_v1_cookie_path, as: :json
    end

    assert_response :ok
    assert response.parsed_body["show_banner"]
  end

  test "PATCH update returns 200 and sets jit_preference_consented cookie with app domain" do
    controller = Apex::App::Web::V1::CookiesController
    expires_at = Time.utc(2030, 1, 2, 3, 4, 5)

    with_env("COOKIE_DOMAIN_APP", ".app.example.test") do
      controller.any_instance.stub(
        :decode_and_verify_preference_jwt,
        { "preferences" => { "consented" => true }, "public_id" => "pref-app-public-id" },
      ) do
        controller.any_instance.stub(:refresh_token_expires_at, expires_at) do
          patch apex_app_web_v1_cookie_path, as: :json
        end
      end
    end

    assert_response :ok
    assert response.parsed_body["show_banner"]
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "jit_preference_consented=1"
    assert_includes set_cookie, "domain=.app.example.test"
    assert_includes set_cookie.downcase, "path=/"
    expires = response_cookie_expiry("jit_preference_consented")

    assert_not_nil expires
    assert_in_delta expires_at.to_i, expires.to_i, 1
  end

  test "PATCH update with consented true updates preference cookie and issues access token" do
    preference = AppPreference.create!(status_id: AppPreferenceStatus::NOTHING)
    AppPreferenceCookie.create!(
      preference: preference,
      targetable: false,
      performant: false,
      functional: false,
      consented: false,
      consented_at: nil,
    )
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller = Apex::App::Web::V1::CookiesController
    controller.any_instance.stub(
      :decode_and_verify_preference_jwt,
      { "preferences" => { "consented" => false, "consent" => nil }, "public_id" => preference.public_id },
    ) do
      patch apex_app_web_v1_cookie_path, params: { consented: true }, as: :json
    end

    assert_response :ok
    preference.reload

    assert preference.app_preference_cookie.consented
    assert_not_nil preference.app_preference_cookie.consented_at
    set_cookie = response.headers["Set-Cookie"].to_s

    assert_includes set_cookie, "jit_preference_consented="
    assert_includes set_cookie, "#{Preference::CookieName.access}="
  end

  test "PATCH update raises and rolls back consent when access token issue fails" do
    preference = AppPreference.create!(status_id: AppPreferenceStatus::NOTHING)
    cookie = AppPreferenceCookie.create!(
      preference: preference,
      targetable: false,
      performant: false,
      functional: false,
      consented: false,
      consented_at: nil,
    )
    cookies[Preference::CookieName.access] = "dummy.preference.token"

    controller = Apex::App::Web::V1::CookiesController
    controller.any_instance.stub(
      :decode_and_verify_preference_jwt,
      { "preferences" => { "consented" => false, "consent" => nil }, "public_id" => preference.public_id },
    ) do
      controller.any_instance.stub(
        :issue_access_token_from, ->(_) {
                                    raise NoMethodError, "issue_access_token_from"
                                  },
      ) do
        assert_raises(NoMethodError) do
          patch apex_app_web_v1_cookie_path, params: { consented: true }, as: :json
        end
      end
    end

    cookie.reload

    assert_not cookie.consented
    assert_nil cookie.consented_at
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
