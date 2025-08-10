# frozen_string_literal: true

require "test_helper"

class News::App::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_app_health_url
    assert_response :success
    assert_equal "OK", @response.body
  end

  test "should get show with postfix" do
    get docs_app_health_url(format: :html)
    assert_response :success
    assert_equal "OK", @response.body
  end

  test "should not get show when required json file" do
    assert_raise do
      get docs_app_health_url(format: :json)
    end
  end
end
