# frozen_string_literal: true

require "test_helper"

class Api::App::V1::HealthTest < ActionDispatch::IntegrationTest
  test "should get show" do
    assert_raise do
      get api_app_v1_health_url(format: :html)
    end
  end

  test "should get show when required json file" do
    get api_app_v1_health_url
    assert_response :success
    assert_nothing_raised do
      assert_equal "OK", response.parsed_body["status"]
    end
  end

  test "should get show when required json file postfix" do
    get api_app_v1_health_url(format: :json)
    assert_response :success
    assert_nothing_raised do
      assert_equal "OK", response.parsed_body["status"]
    end
  end
end
