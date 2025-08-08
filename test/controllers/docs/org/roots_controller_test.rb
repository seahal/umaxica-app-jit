# frozen_string_literal: true

require "test_helper"

class Docs::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_org_root_url
    assert_response :success
  end
end
