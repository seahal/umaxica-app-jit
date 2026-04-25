# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Post::App::RootsControllerTest < ActionDispatch::IntegrationTest
      include RootThemeCookieHelper

      test "should get show" do
        get distributor.post_app_root_url

        assert_response :success
      end

      test "sets lang attribute on html element" do
        get distributor.post_app_root_url(format: :html)

        assert_response :success
        assert_select("html[lang=?]", "ja")
        assert_not_select("html[lang=?]", "")
      end

      test "renders expected layout structure" do
        get distributor.post_app_root_url

        assert_layout_contract
        assert_select "body", count: 1 do
          assert_select "header" do
            assert_select "h1", text: /#{brand_name}.*\(app\)/
          end
          assert_select "main", count: 1
          assert_select "footer", count: 1 do
            assert_select "small", text: /^©/
          end
        end
      end

      test "generates sha3-384 token digest on root" do
        get distributor.post_app_root_url

        assert_response :success
        assert_equal 48, AppPreference.order(:created_at).last.token_digest.bytesize
      end

      test "sets theme cookie" do
        assert_theme_cookie_for(
          host: "app.localhost",
          path: :post_app_root_path,
          label: "docs app root",
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
