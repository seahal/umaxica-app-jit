# typed: false
# frozen_string_literal: true

require "test_helper"

class Docs::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  include RootThemeCookieHelper

  test "should get show" do
    get docs_org_root_url

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get docs_org_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get docs_org_root_url

    assert_layout_contract
    assert_select "head", count: 1 do
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
      assert_select "title", text: /#{brand_name} \(org\) Documents/
    end
    assert_select "body", count: 1 do
      assert_select "header", minimum: 1
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get docs_org_root_url
    assert_response :success
    assert_equal 48, OrgPreference.order(:created_at).last.token_digest.bytesize
  end

  test "sets theme cookie" do
    assert_theme_cookie_for(
      host: "org.localhost",
      path: :docs_org_root_path,
      label: "docs org root",
      ri: "jp",
    )
  end

  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end
