# frozen_string_literal: true

require "test_helper"

class Auth::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / redirects to new registration path" do
    get auth_org_root_url

    assert_response :redirect
    assert_match %r{^#{new_auth_org_authentication_url}}, response.location
  end

  test "GET / returns redirect status" do
    get auth_org_root_url

    assert_response :redirect
  end

  test "renders layout contract after redirect" do
    get auth_org_root_url

    follow_redirect!
    assert_response :success
    assert_layout_contract
  end
end
