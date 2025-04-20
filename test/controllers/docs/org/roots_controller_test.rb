require "test_helper"

class Docs::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_org_root_url
    assert_response :success
  end
end
