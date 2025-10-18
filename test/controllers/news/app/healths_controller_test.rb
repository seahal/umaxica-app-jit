# frozen_string_literal: true

require "test_helper"

class News::App::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns OK response" do
    get news_app_health_url
    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK html response" do
    get news_app_health_url(format: :html)
    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK json response" do
    get news_app_health_url(format: :json)
    assert_response :success
    assert_includes response.body, "OK"
  end
end
