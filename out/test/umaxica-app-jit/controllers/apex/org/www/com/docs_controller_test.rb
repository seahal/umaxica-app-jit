require "test_helper"

class Apex::Org::Www::Com::DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_apex_org_www_com_doc_url
    assert_response :success
  end
end
