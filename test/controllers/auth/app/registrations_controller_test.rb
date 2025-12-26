# frozen_string_literal: true

require "test_helper"

class Auth::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_registration_url(format: :html), headers: { "Host" => host }

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get new_auth_app_registration_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "shows registration methods and social providers" do
    get new_auth_app_registration_url(format: :html), headers: { "Host" => host }

    assert_response :success

    assert_select "[data-testid=?]", "registration-method", count: 2
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "renders registration layout structure" do
    get new_auth_app_registration_url(format: :html)

    expected_brand = brand_name
    escaped_brand = Regexp.escape(expected_brand)

    assert_select "head", count: 1 do
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", minimum: 1
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
        assert_select "small", text: /#{escaped_brand}$/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "header contains authentication links" do
    get new_auth_app_registration_url(format: :html)

    assert_response :success
    assert_select "header", minimum: 1 do
      assert_select "h1", minimum: 1
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer contains navigation links" do
    get new_auth_app_registration_url(format: :html)

    assert_response :success
    assert_select "footer" do
      # Footer should contain copyright and links
      assert_select "a[href*=?]", ENV["EDGE_SERVICE_URL"], text: "Home"
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  private

  def host
    ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end
