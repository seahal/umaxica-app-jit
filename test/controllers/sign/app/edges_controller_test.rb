# frozen_string_literal: true

require "test_helper"

class Sign::App::EdgesControllerTest < ActionDispatch::IntegrationTest
  test "GET /edge returns nothing" do
    get sign_app_edge_url(ri: "jp")

    assert_response :success
    assert_equal "nothing", response.body
  end
end
