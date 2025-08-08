# frozen_string_literal: true

require "test_helper"

class Docs::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_app_root_url
    assert_response :success
  end
end
