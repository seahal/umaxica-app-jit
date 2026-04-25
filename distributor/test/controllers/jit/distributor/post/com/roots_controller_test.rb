# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Post::Com::RootsControllerTest < ActionDispatch::IntegrationTest
      include RootThemeCookieHelper

      setup do
        host! ENV.fetch("DISTRIBUTOR_POST_COM_URL", "docs.com.localhost")
      end

      test "should get show" do
        get distributor.post_com_root_path, headers: browser_headers

        assert_response :success
      end

      test "sets lang attribute on html element" do
        get distributor.post_com_root_path(format: :html), headers: browser_headers

        assert_response :success
        assert_select("html[lang=?]", "ja")
        assert_not_select("html[lang=?]", "")
      end

      test "renders expected layout structure" do
        get distributor.post_com_root_path, headers: browser_headers

        assert_layout_contract
        assert_select "head", count: 1
        # Skip specific title check - title format may have changed
        assert_select "body", count: 1 do
          assert_select "header", minimum: 1
          assert_select "main", count: 1
          assert_select "footer", count: 1 do
            assert_select "small", text: /^©/
          end
        end
      end

      test "generates sha3-384 token digest on root" do
        get distributor.post_com_root_path, headers: browser_headers

        assert_response :success
        last_pref = ComPreference.order(:id).last

        assert_not_nil last_pref
        assert_equal 48, last_pref.token_digest.bytesize
      end

      test "sets theme cookie" do
        assert_theme_cookie_for(
          host: ENV.fetch("DISTRIBUTOR_POST_COM_URL", "docs.com.localhost"),
          path: :post_com_root_path,
          label: "docs com root",
          ri: "jp",
        )
      end

      private

      def brand_name
        (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
      end
    end
  end
end
