# frozen_string_literal: true

require "test_helper"

class Docs::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_com_root_url
    assert_response :success
  end
end
