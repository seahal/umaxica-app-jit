# typed: false
# frozen_string_literal: true

require "test_helper"

class SignHostEnvTest < ActiveSupport::TestCase
  test "service_url reads IDENTITY_SIGN_APP_URL" do
    with_env("IDENTITY_SIGN_APP_URL" => "sign.app.example.test") do
      assert_equal "sign.app.example.test", ENV["IDENTITY_SIGN_APP_URL"]
      assert_equal "sign.app.example.test", SignHostEnv.service_url
    end
  end

  test "staff_url reads IDENTITY_SIGN_ORG_URL" do
    with_env("IDENTITY_SIGN_ORG_URL" => "sign.org.example.test") do
      assert_equal "sign.org.example.test", SignHostEnv.staff_url
    end
  end

  test "validate! raises when service host is missing" do
    with_env("IDENTITY_SIGN_APP_URL" => nil, "IDENTITY_SIGN_ORG_URL" => "sign.org.example.test") do
      error = assert_raises(SignHostEnv::MissingHostError) { SignHostEnv.validate! }

      assert_includes error.message, "IDENTITY_SIGN_APP_URL"
    end
  end

  test "validate! raises when staff host is missing" do
    with_env("IDENTITY_SIGN_APP_URL" => "sign.app.example.test", "IDENTITY_SIGN_ORG_URL" => nil) do
      error = assert_raises(SignHostEnv::MissingHostError) { SignHostEnv.validate! }

      assert_includes error.message, "IDENTITY_SIGN_ORG_URL"
    end
  end

  test "validate! passes when both hosts are present" do
    with_env("IDENTITY_SIGN_APP_URL" => "sign.app.example.test", "IDENTITY_SIGN_ORG_URL" => "sign.org.example.test") do
      assert_nil SignHostEnv.validate!
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
