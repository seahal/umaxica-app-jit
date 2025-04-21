require "test_helper"

class Docs::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_com_root_url
    assert_select 'h1', 'Docs::Com::Roots#index'
    assert_response :success
  end
end
