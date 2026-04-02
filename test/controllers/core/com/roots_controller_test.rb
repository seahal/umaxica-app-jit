# typed: false
# frozen_string_literal: true

require "test_helper"

module Core::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    include RootThemeCookieHelper

    MAIN_CORPORATE_URL = ENV.fetch(
      "MAIN_CORPORATE_URL",
      ENV.fetch("BACK_CORPORATE_URL", "back-corporate.example.com"),
    )

    test "should redirect to MAIN_CORPORATE_URL" do
      get main_com_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get main_com_root_url

      assert_response :success
      assert_layout_contract
    end

    test "generates sha3-384 token digest on root" do
      get main_com_root_url

      assert_response :success
      assert_equal 48, ComPreference.order(:created_at).last.token_digest.bytesize
    end

    test "sets theme cookie" do
      assert_theme_cookie_for(
        host: "com.localhost",
        path: :main_com_root_path,
        label: "core com root",
        ri: "jp",
      )
    end
  end
end
