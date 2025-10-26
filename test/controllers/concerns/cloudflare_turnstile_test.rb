# frozen_string_literal: true

require "test_helper"

class CloudflareTurnstileConcernTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    include CloudflareTurnstile

    def test_action
      result = cloudflare_turnstile_validation
      render json: result
    end
  end

  setup do
    @controller = TestController.new
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      post "test" => "cloudflare_turnstile_concern_test/test#test_action"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "cloudflare_turnstile_validation returns success in test environment" do
    post test_url, params: { "cf-turnstile-response" => "test_token" }

    assert_response :success
    result = response.parsed_body
    assert_equal true, result["success"]
  end

  test "cloudflare_turnstile_validation bypasses verification in test env" do
    # In test environment, it should always return success
    post test_url, params: {}

    assert_response :success
    result = response.parsed_body
    assert result["success"]
  end

  private

  def test_url
    "http://test.localhost/test"
  end
end
