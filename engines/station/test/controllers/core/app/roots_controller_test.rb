# typed: false
# frozen_string_literal: true

require "test_helper"

module Core::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    include RootThemeCookieHelper

    MAIN_SERVICE_URL = ENV.fetch(
      "MAIN_SERVICE_URL",
      ENV.fetch("BACK_SERVICE_URL", "back-service.example.com"),
    )

    test "should redirect to MAIN_SERVICE_URL" do
      get main_app_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get main_app_root_url

      assert_response :success
      assert_layout_contract
    end

    test "generates sha3-384 token digest on root" do
      get main_app_root_url

      assert_response :success
      assert_equal 48, AppPreference.order(:created_at).last.token_digest.bytesize
    end

    test "sets theme cookie" do
      assert_theme_cookie_for(
        host: "app.localhost",
        path: :main_app_root_path,
        label: "core app root",
        ri: "jp",
      )
    end
  end
end
