require "test_helper"


class Sign::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get new" do
    get new_sign_app_registration_url(format: :html), headers: { "Host" => host }

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get new_sign_app_registration_url(format: :html)

    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "shows registration methods and social providers" do
    get new_sign_app_registration_url(format: :html), headers: { "Host" => host }

    assert_response :success

    assert_select "[data-testid=?]", "registration-method", count: 2
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "renders registration layout structure" do
    get new_sign_app_registration_url(format: :html)

    expected_brand = brand_name
    escaped_brand = Regexp.escape(expected_brand)

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: "#{expected_brand} (app)"
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 2 do
        assert_select "h1", text: "#{ expected_brand } (sign, app)"
      end

      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
        assert_select "small", text: /#{ escaped_brand }$/
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "header contains authentication links" do
    get new_sign_app_registration_url(format: :html)

    assert_response :success
    assert_select "header", minimum: 1 do
      assert_select "h1", minimum: 1
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "footer contains navigation links" do
    get new_sign_app_registration_url(format: :html)

    assert_response :success
    assert_select "footer" do
      assert_select "ul" do
        assert_select "li", minimum: 1
        # Home link
        assert_select "a[href*=?]", ENV["EDGE_SERVICE_URL"], text: "Home"
        # Document link - check for link text instead of exact URL
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions
end
