require "test_helper"

class Docs::Org::TermsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_org_terms_url
    assert_select "h1", "Docs::Org::Terms#index"
    assert_select "p", "Find me in app/views/docs/org/terms/index.html.erb"
    assert_response :success
    assert_equal "text/html", @response.media_type
  end
end
