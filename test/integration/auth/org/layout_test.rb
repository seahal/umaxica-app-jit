require "test_helper"

class Auth::Org::LayoutTest < ActionDispatch::IntegrationTest
  def default_headers
    { "Host" => ENV["AUTH_STAFF_URL"] || "auth.org.localhost" }
  end

  def login_headers(staff)
    default_headers.merge("X-TEST-CURRENT-STAFF" => staff.id.to_s)
  end

  # rubocop:disable Minitest/MultipleAssertions
  # test "layout links when not logged in" do
  #   get new_auth_org_registration_url, headers: default_headers

  #   assert_response :success

  #   assert_select "header" do
  #     assert_select "a[href*=?]", "/registration/new", text: I18n.t("auth.org.layout.nav.sign_up")
  #     assert_select "a[href*=?]", "/authentication/new", text: I18n.t("auth.org.layout.nav.log_in")
  #     assert_select "a[href*=?][data-turbo-method='delete']", "/authentication", count: 0
  #   end
  # end

  # test "layout links when logged in" do
  #   staff = staffs(:one)
  #   # Assuming there is a page we can visit when logged in.
  #   # new_auth_org_registration_url might redirect if logged in?
  #   # Let's check Auth::Org::RegistrationsController.
  #   # But for now let's try accessing setting page since we added it.
  #   get auth_org_setting_url, headers: login_headers(staff)

  #   assert_response :success

  #   assert_select "header" do
  #     assert_select "a[href*=?]", "/registration/new", count: 1
  #     assert_select "a[href*=?]", "/authentication/new", count: 1
  #     assert_select "a[href*=?][data-turbo-method='delete']", "/authentication", count: 0
  #   end
  # end
  # rubocop:enable Minitest/MultipleAssertions
end
