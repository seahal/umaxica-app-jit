# frozen_string_literal: true

require "test_helper"

class Apex::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get health status with json response" do
    get apex_com_health_url
    assert_response :success

    response_data = response.parsed_body
    assert_equal "healthy", response_data["status"]
    assert_not_nil response_data["timestamp"]
    assert_equal "1.0.0", response_data["version"]
    assert_includes response_data, "services"
  end

  test "should include service health checks" do
    get apex_com_health_url
    assert_response :success

    response_data = response.parsed_body
    services = response_data["services"]
    assert_includes services, "database"
    assert_includes services, "cache"
    assert_includes services, "external_apis"
  end

  test "should return proper content type" do
    get apex_com_health_url
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end
end
