# typed: false
# frozen_string_literal: true

require "test_helper"

class SignHostEnvCoverageTest < ActiveSupport::TestCase
  test "service and staff urls come from env and validate all required hosts" do
    with_env("IDENTITY_SIGN_APP_URL" => "sign.app.example.test", "IDENTITY_SIGN_ORG_URL" => "sign.org.example.test") do
      assert_equal "sign.app.example.test", SignHostEnv.service_url
      assert_equal "sign.org.example.test", SignHostEnv.staff_url
      assert_nil SignHostEnv.validate!
    end

    with_env("IDENTITY_SIGN_APP_URL" => nil, "IDENTITY_SIGN_ORG_URL" => nil) do
      error = assert_raises(SignHostEnv::MissingHostError) { SignHostEnv.validate! }

      assert_includes error.message, "IDENTITY_SIGN_APP_URL"
      assert_includes error.message, "IDENTITY_SIGN_ORG_URL"
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
