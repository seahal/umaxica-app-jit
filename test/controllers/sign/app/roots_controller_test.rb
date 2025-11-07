# frozen_string_literal: true

require "test_helper"

class Sign::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / redirects to new registration path" do
    get sign_app_root_url

    assert_response :redirect
    assert_match %r{^#{new_sign_app_registration_url}}, response.location
  end

  test "GET / returns redirect status" do
    get sign_app_root_url

    assert_response :redirect
  end
end
