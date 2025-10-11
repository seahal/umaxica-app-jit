require "test_helper"

class Auth::Org::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_registration_url(format: :html), headers: { "Host" => host }
    assert_response :not_found
  end

  test "check dom" do
    get new_auth_org_registration_url(format: :html)

    assert_select "head", count: 1 do
      assert_select "title", count: 1, text: /#{ ENV.fetch('NAME') }/
      assert_select "link[rel=?]", "icon", count: 1
    end
    assert_select "body", count: 1 do
      assert_select "header", count: 2 do
        assert_select "h1", text: "#{ ENV.fetch('NAME') } (auth, org)"
      end
      assert_select "main", count: 1
      assert_select "footer", count: 1 do
        assert_select "small", text: /^©/
      end
    end
  end
end
