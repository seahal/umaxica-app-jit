# frozen_string_literal: true

require "test_helper"

class DefaultUrlOptionsTest < ActiveSupport::TestCase
  class TestController < ApplicationController
    include DefaultUrlOptions

    attr_accessor :request, :response

    def cookies
      request.cookie_jar
    end
  end

  setup do
    @controller = TestController.new
    @controller.request = ActionDispatch::TestRequest.create
    @controller.response = ActionDispatch::TestResponse.new
  end

  test "read_cookie_preferences_for_url returns empty hash for blank cookie" do
    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal({}, result)
  end

  test "read_cookie_preferences_for_url handles JSON parse error gracefully" do
    # Simulate invalid JSON in cookie by directly setting the cookie value
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[:root_app_preferences] = "invalid json"

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal({}, result)
  end

  test "read_cookie_preferences_for_url handles TypeError gracefully" do
    # Simulate type error scenario
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[:root_app_preferences] = nil

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal({}, result)
  end

  test "read_cookie_preferences_for_url returns empty hash for non-hash JSON" do
    # Set a JSON array instead of hash
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[:root_app_preferences] = JSON.generate([ "array", "value" ])

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal({}, result)
  end

  test "read_cookie_preferences_for_url extracts preference values" do
    # Set valid preference cookie as JSON string
    preferences = { "lx" => "en", "ri" => "us", "tz" => "utc" }
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[:root_app_preferences] = JSON.generate(preferences)

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal "en", result[:lx]
    assert_equal "us", result[:ri]
    assert_equal "utc", result[:tz]
  end

  test "read_cookie_preferences_for_url compacts nil values" do
    # Set partial preferences as JSON string
    preferences = { "lx" => "en", "ri" => nil, "tz" => "utc" }
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[:root_app_preferences] = JSON.generate(preferences)

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal "en", result[:lx]
    assert_equal "utc", result[:tz]
    assert_nil result[:ri]
  end
end
