require "test_helper"

class Docs::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_app_root_url
    assert_select 'h1', 'Docs::App::Roots#index'
    assert_response :success
  end
end
