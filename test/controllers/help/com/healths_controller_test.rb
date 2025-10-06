# frozen_string_literal: true

require "test_helper"

class Help::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_com_health_url
    assert_response :success
    assert_includes @response.body, "OK"
  end

  test "should get show with postfix" do
    get help_com_health_url(format: :html)
    assert_response :success
    assert_includes @response.body, "OK"
  end

  test "should get show with postfix json" do
    get help_com_health_url(format: :json)
    assert_response :success
    assert_equal "OK", @response.parsed_body["status"]
  end

  test "should not get show when required yaml file" do
    assert_raises(RuntimeError) do
      get help_com_health_url(format: :yaml)
    end
  end
end
