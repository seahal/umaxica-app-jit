# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Jit::Foundation::Base::Com
      class RootsControllerTest < ActionDispatch::IntegrationTest
        include RootThemeCookieHelper

        FOUNDATION_BASE_COM_URL = ENV.fetch(
          "FOUNDATION_BASE_COM_URL",
          ENV.fetch("BACK_CORPORATE_URL", "back-corporate.example.com"),
        )

        test "should redirect to FOUNDATION_BASE_COM_URL" do
          get foundation.base_com_root_url

          assert_response :success
        end

        test "renders layout contract" do
          get foundation.base_com_root_url

          assert_response :success
          assert_layout_contract
        end

        test "generates sha3-384 token digest on root" do
          get foundation.base_com_root_url

          assert_response :success
          assert_equal 48, ComPreference.order(:created_at).last.token_digest.bytesize
        end

        test "sets theme cookie" do
          assert_theme_cookie_for(
            host: "com.localhost",
            path: :base_com_root_path,
            label: "core com root",
            ri: "jp",
          )
        end
      end
    end
  end
end
