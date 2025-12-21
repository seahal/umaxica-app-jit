require "test_helper"

class Auth::App::LayoutTest < ActionDispatch::IntegrationTest
  def default_headers
    { "Host" => ENV["SIGN_SERVICE_URL"] || "sign.app.localhost" }
  end

  def login_headers(user)
    default_headers.merge("X-TEST-CURRENT-USER" => user.id.to_s)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "layout links when not logged in" do
    get new_auth_app_registration_email_url, headers: default_headers

    assert_response :success

    assert_select "nav" do
      assert_select "a[href*=?]", "/registration/new", text: I18n.t("auth.app.layout.nav.sign_up")
      assert_select "a[href*=?]", "/authentication/new", text: I18n.t("auth.app.layout.nav.log_in")
      assert_select "a[href*=?]", "/setting", count: 0
      assert_select "a[href*=?][data-turbo-method='delete']", "/authentication", count: 0
    end
  end

  # test "layout links when logged in" do
  #   user = users(:one)
  #   get new_auth_app_registration_telephone_url, headers: login_headers(user)

  #   assert_response :success

  #   assert_select "nav" do
  #     assert_select "a[href*=?]", "/registration/new", count: 1
  #     assert_select "a[href*=?]", "/authentication/new", count: 1
  #     assert_select "a[href*=?]", "/setting", count: 0
  #     assert_select "a[href*=?][data-turbo-method='delete']", "/authentication", count: 0
  #   end
  # end
  # rubocop:enable Minitest/MultipleAssertions
end
