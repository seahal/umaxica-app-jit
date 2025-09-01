# frozen_string_literal: true

require "test_helper"

class Help::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_com_root_url
    assert_response :success
  end
end
