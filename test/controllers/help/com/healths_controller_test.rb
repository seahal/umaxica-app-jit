# frozen_string_literal: true

require "test_helper"

class Help::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Help::Com::ApplicationController.define_method(:canonicalize_regional_params) { nil }
  end

  teardown do
    begin
      Help::Com::ApplicationController.remove_method(:canonicalize_regional_params)
    rescue NameError
      # Ignore
    end
  end

  test "GET /health returns OK response" do
    get help_com_health_url()

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK html response" do
    get help_com_health_url(format: :html)

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK json response" do
    get help_com_health_url(format: :json)

    assert_response :success
    assert_includes response.body, "OK"
  end
end
