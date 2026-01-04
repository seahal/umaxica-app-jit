# frozen_string_literal: true

require "test_helper"

class Sign::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / redirects to new registration path" do
    get sign_org_root_url

    assert_response :redirect
    assert_match %r{^#{new_sign_org_authentication_url}}, response.location
  end

  test "GET / returns redirect status" do
    get sign_org_root_url

    assert_response :redirect
  end

  test "renders layout contract after redirect" do
    get sign_org_root_url

    follow_redirect!
    assert_response :success
    assert_layout_contract
  end
end
