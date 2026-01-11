# frozen_string_literal: true

require "test_helper"

class News::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  include RootThemeCookieHelper

  test "should get show" do
    get news_com_root_url

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get news_com_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "sys")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get news_com_root_url

    assert_layout_contract
    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{brand_name} (com) Newsroom"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1 do
        assert_select "h1", text: "#{brand_name} (com)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get news_com_root_url
    assert_response :success
    assert_equal 48, ComPreference.order(:created_at).last.token_digest.bytesize
  end

  test "sets theme cookie" do
    assert_theme_cookie_for(host: "com.localhost", path: :news_com_root_path, label: "news com root")
  end

  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end
