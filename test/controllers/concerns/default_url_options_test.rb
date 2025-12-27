# frozen_string_literal: true

require "test_helper"
class DefaultUrlOptionsTest < ActiveSupport::TestCase
  # rubocop:disable Rails/ApplicationController
  class TestController < ActionController::Base
    include DefaultUrlOptions

    attr_accessor :request, :response

    def cookies
      request.cookie_jar
    end

    def controller_path
      "peak/app/preferences"
    end
  end
  # rubocop:enable Rails/ApplicationController

  setup do
    @controller = TestController.new
    @controller.request = ActionDispatch::TestRequest.create
    @controller.request.host = "app.localhost"
    @controller.response = ActionDispatch::TestResponse.new
  end

  test "read_cookie_preferences_for_url returns empty hash for blank cookie" do
    result = @controller.send(:read_cookie_preferences_for_url)

    assert_empty(result)
  end

  test "read_cookie_preferences_for_url handles invalid token gracefully" do
    cookie_jar = @controller.request.cookie_jar
    cookie_jar[@controller.send(:preference_cookie_key)] = "invalid.token"

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_empty(result)
  end

  test "read_cookie_preferences_for_url handles legacy JSON gracefully" do
    cookie_jar = @controller.request.cookie_jar
    cookie_jar.signed[@controller.send(:preference_cookie_key)] = JSON.generate(["array", "value"])

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_empty(result)
  end

  test "read_cookie_preferences_for_url extracts preference values" do
    preferences = { "lx" => "en", "ri" => "us", "tz" => "utc" }
    token = PreferenceToken.encode(preferences, host: @controller.request.host)
    cookie_jar = @controller.request.cookie_jar
    cookie_jar[@controller.send(:preference_cookie_key)] = token

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal "en", result[:lx]
    assert_equal "us", result[:ri]
    assert_equal "utc", result[:tz]
  end

  test "read_cookie_preferences_for_url compacts nil values" do
    preferences = { "lx" => "en", "ri" => nil, "tz" => "utc" }
    token = PreferenceToken.encode(preferences, host: @controller.request.host)
    cookie_jar = @controller.request.cookie_jar
    cookie_jar[@controller.send(:preference_cookie_key)] = token

    result = @controller.send(:read_cookie_preferences_for_url)

    assert_equal "en", result[:lx]
    assert_equal "utc", result[:tz]
    assert_nil result[:ri]
  end
end
