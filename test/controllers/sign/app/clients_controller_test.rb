# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::ClientsControllerTest < ActionDispatch::IntegrationTest
  test "GET /client returns nothing" do
    get sign_app_client_url(ri: "jp")

    assert_response :success
    assert_equal "nothing", response.body
  end
end
