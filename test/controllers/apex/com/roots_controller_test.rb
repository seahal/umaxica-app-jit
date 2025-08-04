# frozen_string_literal: true

require "test_helper"

class Apex::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_com_root_url
    assert_response :success
  end
end
