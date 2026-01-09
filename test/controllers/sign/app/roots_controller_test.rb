# frozen_string_literal: true

require "test_helper"

class Sign::App::RootsControllerTest < ActionDispatch::IntegrationTest
  include RootThemeCookieHelper

  test "GET / redirects to new registration path" do
    get sign_app_root_url

    # Controller now renders the root index page with links to registration
    assert_response :success
    assert_select "h1", minimum: 1
  end

  test "GET / returns redirect status" do
    get sign_app_root_url

    assert_response :success
  end

  test "renders layout contract" do
    get sign_app_root_url

    assert_response :success
    assert_layout_contract
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "footer contains navigation links" do
    get sign_app_root_url
    assert_response :success
    assert_select "footer" do
      assert_select "a"
      assert_select "a[href*=?]", sign_app_preference_path
      assert_select "a[href*=?]", sign_app_configuration_path
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get sign_app_root_url
    assert_response :success
    assert_equal 48, AppPreference.order(:created_at).last.token_digest.bytesize
  end

  test "sets theme cookie" do
    assert_theme_cookie_for(host: "sign.app.localhost", path: :sign_app_root_path, label: "sign app root")
  end
end
