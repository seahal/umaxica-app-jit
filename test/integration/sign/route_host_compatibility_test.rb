# typed: false
# frozen_string_literal: true

require "test_helper"

class SignRouteHostCompatibilityTest < ActionDispatch::IntegrationTest
  test "sign app routes still match AUTH_SERVICE_URL during migration" do
    with_env("SIGN_SERVICE_URL" => nil, "AUTH_SERVICE_URL" => "legacy-sign.app.example.test") do
      Rails.application.reload_routes!
      host! "legacy-sign.app.example.test"

      get "/"

      assert_not_equal 404, response.status
    end
  ensure
    Rails.application.reload_routes!
  end

  test "sign org routes still match AUTH_STAFF_URL during migration" do
    with_env("SIGN_STAFF_URL" => nil, "AUTH_STAFF_URL" => "legacy-sign.org.example.test") do
      Rails.application.reload_routes!
      host! "legacy-sign.org.example.test"

      get "/"

      assert_not_equal 404, response.status
    end
  ensure
    Rails.application.reload_routes!
  end

  private

  def with_env(vars)
    original = {}
    vars.each_key { |key| original[key] = ENV[key] }

    vars.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
