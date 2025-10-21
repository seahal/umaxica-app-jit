require "test_helper"

class Sign::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get new" do
    get new_sign_app_registration_url(format: :html), headers: { "Host" => host }
    assert_response :success
  end

  test "should get html which must have html which contains lang param." do
    get new_sign_app_registration_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end

  # test "shows registration methods and social providers" do
  #   get new_sign_app_registration_url(format: :html), headers: { "Host" => host }
  #   assert_response :success
  #
  #   assert_select "[data-testid=?]", "registration-method", count: 2
  #
  #   assert_select "[data-testid=?]", "registration-social" do
  #     assert_select "form[action=?][method=?]", "/sign/google_oauth2", "post"
  #     assert_select "form[action=?][method=?]", "/sign/apple", "post"
  #   end
  #
  #   assert_select "[data-testid=?]", "registration-sign-in" do
  #     assert_select "a[href=?]", new_sign_app_authentication_path
  #   end
  # end

  test "renders localized copy with product name fallback" do
    get new_sign_app_registration_url(format: :html), headers: { "Host" => host }
    assert_response :success
    assert_select "p", text: "log in?"
  end

  test "check dom" do
    get new_sign_app_registration_url(format: :html)

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: /#{ ENV.fetch('NAME') }/
      assert_select "link[rel=?][sizes=?]", "icon", "32x32", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 2 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (sign, app)"
      end

      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
        assert_select "small", text: /#{ ENV.fetch('NAME') }$/
      end
    end
  end
end
