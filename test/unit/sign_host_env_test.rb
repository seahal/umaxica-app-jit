# typed: false
# frozen_string_literal: true

require "test_helper"

class SignHostEnvTest < ActiveSupport::TestCase
  test "service_url falls back to AUTH_SERVICE_URL" do
    with_env("SIGN_SERVICE_URL" => nil, "AUTH_SERVICE_URL" => "legacy-sign.app.example.test") do
      assert_equal "legacy-sign.app.example.test", SignHostEnv.service_url
    end
  end

  test "staff_url falls back to AUTH_STAFF_URL" do
    with_env("SIGN_STAFF_URL" => nil, "AUTH_STAFF_URL" => "legacy-sign.org.example.test") do
      assert_equal "legacy-sign.org.example.test", SignHostEnv.staff_url
    end
  end

  test "apply_legacy_fallbacks! does not overwrite SIGN_SERVICE_URL" do
    with_env("SIGN_SERVICE_URL" => "sign.app.example.test", "AUTH_SERVICE_URL" => "legacy-sign.app.example.test") do
      SignHostEnv.apply_legacy_fallbacks!

      assert_equal "sign.app.example.test", ENV["SIGN_SERVICE_URL"]
    end
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
