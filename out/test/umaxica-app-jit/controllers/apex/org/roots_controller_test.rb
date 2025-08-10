# frozen_string_literal: true

require "test_helper"

class Apex::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_org_root_url
    assert_response :success
  end
end
