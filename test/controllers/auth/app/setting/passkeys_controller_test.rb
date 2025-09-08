# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  test "should get index" do
    get auth_app_setting_passkeys_url, headers: { "Host" => @host }
    assert_response :success
  end

  # test "POST challenge responds unauthorized without user" do
  #   User.stub(:last, nil) do
  #     post challenge_auth_app_setting_passkeys_url, headers: { "Host" => @host }
  #     assert_response :unauthorized
  #     body = @response.parsed_body
  #     assert body.is_a?(Hash)
  #     assert body["error"].present?
  #   end
  # end
  #
  # test "POST challenge returns creation options when user exists" do
  #   dummy = Class.new do
  #     attr_accessor :webauthn_id
  #     def initialize; @webauthn_id = nil; end
  #     def update!(attrs)
  #       @webauthn_id = attrs[:webauthn_id]
  #       true
  #     end
  #     def try(_name); nil; end
  #   end.new
  #
  #   User.stub(:last, dummy) do
  #     post challenge_auth_app_setting_passkeys_url, headers: { "Host" => @host }
  #   end
  #   assert_response :success
  #
  #   body = @response.parsed_body
  #   assert body.present?, "expected JSON body"
  #   # Depending on webauthn gem serialization, either top-level fields or nested under publicKey
  #   assert body["publicKey"].present? || body["challenge"].present?, "expected WebAuthn creation options"
  # end
  #
  # test "POST challenge populates webauthn_id when blank" do
  #   dummy = Class.new do
  #     attr_accessor :webauthn_id
  #     def initialize; @webauthn_id = nil; end
  #     def update!(attrs)
  #       @webauthn_id = attrs[:webauthn_id]
  #       true
  #     end
  #     def try(_name); nil; end
  #   end.new
  #
  #   User.stub(:last, dummy) do
  #     post challenge_auth_app_setting_passkeys_url, headers: { "Host" => @host }
  #   end
  #
  #   assert_response :success
  # end
  #
  # test "POST challenge handles WebAuthn errors" do
  #   dummy = Object.new
  #   def dummy.webauthn_id = "x"
  #   def dummy.try(_); nil; end
  #
  #   User.stub(:last, dummy) do
  #     WebAuthn::Credential.stub(:options_for_create, ->(*) { raise WebAuthn::Error, "bad" }) do
  #       post challenge_auth_app_setting_passkeys_url, headers: { "Host" => @host }
  #     end
  #   end
  #
  #   assert_response :unprocessable_content
  #   body = @response.parsed_body
  #   assert_equal "bad", body["error"]
  # end

  # test "POST verify returns ok json" do
  #   post verify_auth_app_setting_passkeys_url, headers: { "Host" => @host }
  #   assert_response :success
  #   body = @response.parsed_body
  #   assert_equal "ok", body["status"]
  # end
end
