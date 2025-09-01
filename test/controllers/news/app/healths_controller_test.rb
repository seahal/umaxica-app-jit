# frozen_string_literal: true

require "test_helper"

class News::App::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get news_app_health_url
    assert_response :success
    assert_equal "OK", @response.body
  end

  test "should get show with postfix" do
    get news_app_health_url(format: :html)
    assert_response :success
    assert_equal "OK", @response.body
  end

  test "should get show with postfix json" do
    get news_app_health_url(format: :json)
    assert_response :success
    assert_equal "OK", @response.parsed_body["status"]
  end

  test "should not get show when required yaml file" do
    assert_raises(RuntimeError) do
      get news_app_health_url(format: :yaml)
    end
  end
end
