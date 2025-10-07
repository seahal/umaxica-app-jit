# frozen_string_literal: true

require "test_helper"

class Apex::Net::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_net_health_url
    assert_response :success
    assert_includes @response.body, "OK"
  end

  test "should get show with postfix" do
    get apex_net_health_url(format: :html)
    assert_response :success
    assert_includes @response.body, "OK"
  end

  test "should get show with postfix json" do
    get apex_net_health_url(format: :json)
    assert_response :success
    assert_equal "OK", @response.parsed_body["status"]
  end

  test "should not get show when required yaml file" do
    assert_raises(RuntimeError) do
      get apex_net_health_url(format: :yaml)
    end
  end
end
