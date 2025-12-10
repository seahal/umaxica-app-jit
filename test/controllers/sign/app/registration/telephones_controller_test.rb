# frozen_string_literal: true

require "test_helper"

module Sign::App::Registration
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_app_registration_telephone_url

      assert_response :success
    end

    test "should clear session on new" do
      get new_sign_app_registration_telephone_url

      assert_response :success
      assert_nil session[:user_telephone_registration]
    end

    test "edit returns bad_request when not logged in and no session" do
      get edit_sign_app_registration_telephone_url(id: "test-id"), headers: default_headers

      assert_response :bad_request
    end

    test "i18n flash messages for telephone registration flow exist" do
      # Check that all required i18n keys for telephone registration exist
      session_expired_key = "sign.app.registration.telephone.edit.session_expired"
      create_key = "sign.app.registration.telephone.create.verification_code_sent"
      update_key = "sign.app.registration.telephone.update.success"

      assert_not_nil I18n.t(session_expired_key, default: nil)
      assert_not_nil I18n.t(create_key, default: nil)
      assert_not_nil I18n.t(update_key, default: nil)
    end

    test "return page link text uses i18n" do
      # Check that the return page link text key exists
      return_page_key = "controller.sign.app.registration.telephone.edit.return_page"

      assert_not_nil I18n.t(return_page_key, default: nil)
    end

    # Turnstile Widget Verification Tests
    test "new registration telephone page renders Turnstile widget" do
      get new_sign_app_registration_telephone_url, headers: default_headers

      assert_response :success
      assert_select "div[id^='cf-turnstile-']", count: 1
    end

    private

    def default_headers
      { "Host" => host }
    end

    def host
      ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    end
  end
end
