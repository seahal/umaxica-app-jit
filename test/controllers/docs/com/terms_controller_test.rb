require "test_helper"

class Docs::Com::TermsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_com_term_url
    assert_select "p", "Find me in app/views/docs/com/terms/index.html.erb"
    assert_response :success
    assert_equal "text/html", @response.media_type
  end
end
