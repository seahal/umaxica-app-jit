# frozen_string_literal: true

require "test_helper"

class Help::App::RootsControllerTest < ActionDispatch::IntegrationTest
  include RootThemeCookieHelper

  test "should get show" do
    get help_app_root_url()

    assert_response :success
  end

  test "redirects to canonical path by stripping ri=jp" do
    get help_app_root_url(ri: "jp", lx: "en", foo: "bar")

    assert_response :moved_permanently
    assert_redirected_to help_app_root_url(lx: "en", foo: "bar")
    assert_nil request.path_parameters[:ri]
  end

  test "sets lang attribute on html element" do
    get help_app_root_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  test "renders contact link" do
    get help_app_root_url()

    assert_response :success
    assert_select "a[href*=?]", "/contacts/new"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "renders expected layout structure" do
    get help_app_root_url()

    assert_layout_contract
    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{brand_name} (app) Help Center"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 1
      assert_select "main", count: 1
      assert_select "footer", count: 1
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get help_app_root_url()
    assert_response :success
    assert_equal 48, AppPreference.order(:created_at).last.token_digest.bytesize
  end

  test "sets theme cookie" do
    host! "app.localhost"
    get help_app_root_path
    assert_redirected_to help_app_root_url(ri: "jp", host: "app.localhost")
    assert_not_nil cookies[:ct]
  end

  private

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end
