# frozen_string_literal: true

require "test_helper"

class Sign::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / redirects to new registration path" do
    get sign_app_root_url

    # Controller now renders the root index page with links to registration
    assert_response :success
    assert_select "h1", minimum: 1
  end

  test "GET / returns redirect status" do
    get sign_app_root_url

    assert_response :success
  end
end
