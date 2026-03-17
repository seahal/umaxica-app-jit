# typed: false
# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    Preference = ::Preference unless const_defined?(:Preference)
    Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
    Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)

    module Edge
      module V0
        Preference = ::Preference unless const_defined?(:Preference)
        Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
        Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)
      end
    end
  end

  module Com
    Preference = ::Preference unless const_defined?(:Preference)
    Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
    Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)

    module Edge
      module V0
        Preference = ::Preference unless const_defined?(:Preference)
        Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
        Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)
      end
    end
  end

  module Org
    Preference = ::Preference unless const_defined?(:Preference)
    Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
    Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)

    module Edge
      module V0
        Preference = ::Preference unless const_defined?(:Preference)
        Preference::IoKeys = ::Preference::IoKeys unless Preference.const_defined?(:IoKeys)
        Preference::CookieName = ::Preference::CookieName unless Preference.const_defined?(:CookieName)
      end
    end
  end
end

class DbscRegistrationsControllerTest < ActiveSupport::TestCase
  FakeRequest = Struct.new(:headers, :base_url, :host, keyword_init: true)

  class FakeResponse
    attr_reader :headers

    def initialize
      @headers = {}
    end

    def set_header(key, value)
      @headers[key] = value
    end
  end

  class FakeRecord
    attr_reader :dbsc_session_id, :updated_attributes

    def initialize(dbsc_session_id: "session-123")
      @dbsc_session_id = dbsc_session_id
      @updated_attributes = nil
    end

    def update!(attributes)
      @updated_attributes = attributes
    end
  end

  AUTH_CASES = [
    {
      klass: Sign::App::Edge::V0::Token::DbscRegistrationsController,
      url_helper: :sign_app_edge_v0_token_dbsc_registration_url,
      cookie_setter: :set_dbsc_cookie!,
      cookie_expiry: :dbsc_cookie_expires_at_for,
      cookie_name: Auth::Base::DBSC_COOKIE_KEY,
      session_header: Auth::IoKeys::Headers::DBSC_SESSION_ID,
      proof_header: Auth::IoKeys::Headers::DBSC_RESPONSE,
      challenge_header: Auth::IoKeys::Headers::DBSC_CHALLENGE,
      verification_service: Dbsc::VerificationService,
      registration_service: Dbsc::RegistrationService,
    },
    {
      klass: Sign::Org::Edge::V0::Token::DbscRegistrationsController,
      url_helper: :sign_org_edge_v0_token_dbsc_registration_url,
      cookie_setter: :set_dbsc_cookie!,
      cookie_expiry: :dbsc_cookie_expires_at_for,
      cookie_name: Auth::Base::DBSC_COOKIE_KEY,
      session_header: Auth::IoKeys::Headers::DBSC_SESSION_ID,
      proof_header: Auth::IoKeys::Headers::DBSC_RESPONSE,
      challenge_header: Auth::IoKeys::Headers::DBSC_CHALLENGE,
      verification_service: Dbsc::VerificationService,
      registration_service: Dbsc::RegistrationService,
    },
  ].freeze

  PREFERENCE_CASES = [
    {
      klass: Apex::App::Edge::V0::DbscRegistrationsController,
      url_helper: :apex_app_edge_v0_dbsc_registration_url,
    },
    {
      klass: Apex::Com::Edge::V0::DbscRegistrationsController,
      url_helper: :apex_com_edge_v0_dbsc_registration_url,
    },
    {
      klass: Apex::Org::Edge::V0::DbscRegistrationsController,
      url_helper: :apex_org_edge_v0_dbsc_registration_url,
    },
  ].map do |config|
    config.merge(
      cookie_setter: :set_preference_dbsc_cookie!,
      cookie_expiry: :preference_dbsc_cookie_expires_at,
      cookie_name: Preference::CookieName.dbsc,
      session_header: Preference::IoKeys::Headers::DBSC_SESSION_ID,
      proof_header: Preference::IoKeys::Headers::DBSC_RESPONSE,
      challenge_header: Preference::IoKeys::Headers::DBSC_CHALLENGE,
      verification_service: Dbsc::VerificationService,
      registration_service: Dbsc::RegistrationService,
    )
  end.freeze

  (AUTH_CASES + PREFERENCE_CASES).each do |config|
    test "#{config[:klass].name} handles registration success and failure" do
      controller = build_controller(config[:klass], headers: { config[:proof_header] => "proof" })
      record = FakeRecord.new(dbsc_session_id: "session-abc")

      controller.define_singleton_method(:current_session) { nil } if controller.respond_to?(:current_session)
      controller.define_singleton_method(:token_from_refresh_cookie) {
        nil
      } if controller.respond_to?(:token_from_refresh_cookie)
      controller.define_singleton_method(:current_preference_record) {
        record
      } if controller.respond_to?(:current_preference_record, true)
      controller.define_singleton_method(config[:url_helper]) { "https://example.test/dbsc" }
      controller.define_singleton_method(config[:cookie_expiry]) { |_value| 1.hour.from_now }

      cookie_args = nil
      controller.define_singleton_method(config[:cookie_setter]) do |session_id, expires_at:|
        cookie_args = { session_id:, expires_at: }
      end

      config[:registration_service].stub :call, { ok: true, session_id: "session-abc", record: record } do
        controller.send(:handle_registration)
      end

      rendered = controller.instance_variable_get(:@_test_rendered)

      assert_equal :created, rendered[:status]
      assert_equal "session-abc", rendered[:json][:session_identifier]
      assert_equal config[:cookie_name], rendered[:json][:credentials].first[:name]
      assert_equal "session-abc", cookie_args[:session_id]

      controller = build_controller(config[:klass], headers: { config[:proof_header] => "proof" })
      controller.define_singleton_method(:current_session) { nil } if controller.respond_to?(:current_session)
      controller.define_singleton_method(:token_from_refresh_cookie) {
        nil
      } if controller.respond_to?(:token_from_refresh_cookie)
      controller.define_singleton_method(:current_preference_record) {
        record
      } if controller.respond_to?(:current_preference_record, true)
      controller.define_singleton_method(config[:url_helper]) { "https://example.test/dbsc" }

      config[:registration_service].stub :call, { ok: false, error_code: "invalid_proof" } do
        controller.send(:handle_registration)
      end

      rendered = controller.instance_variable_get(:@_test_rendered)

      assert_equal :unprocessable_content, rendered[:status]
      assert_equal "invalid_proof", rendered[:json][:error_code]
    end

    test "#{config[:klass].name} handles refresh challenge, verification failure, and success" do
      controller = build_controller(
        config[:klass],
        headers: { config[:session_header] => %("session-abc"), config[:proof_header] => "" },
      )
      record = FakeRecord.new(dbsc_session_id: "session-abc")

      controller.define_singleton_method(:dbsc_token_record) {
        record
      } if controller.respond_to?(:dbsc_token_record, true)
      controller.define_singleton_method(:current_preference_record) {
        record
      } if controller.respond_to?(:current_preference_record, true)
      controller.define_singleton_method(:issue_dbsc_challenge_for!) { |_value|
        "challenge-1"
      } if controller.respond_to?(:issue_dbsc_challenge_for!, true)
      controller.define_singleton_method(:issue_preference_dbsc_challenge_for!) { |_value|
        "challenge-1"
      } if controller.respond_to?(:issue_preference_dbsc_challenge_for!, true)
      controller.send(:handle_bound_cookie_refresh)

      assert_equal :forbidden, controller.instance_variable_get(:@_test_head_status)
      assert_includes controller.response.headers[config[:challenge_header]], "challenge-1"

      controller = build_controller(
        config[:klass],
        headers: { config[:session_header] => %("session-abc"), config[:proof_header] => "proof" },
      )
      controller.define_singleton_method(:dbsc_token_record) {
        record
      } if controller.respond_to?(:dbsc_token_record, true)
      controller.define_singleton_method(:current_preference_record) {
        record
      } if controller.respond_to?(:current_preference_record, true)
      controller.define_singleton_method(config[:url_helper]) { "https://example.test/dbsc" }

      config[:verification_service].stub :call, { ok: false, error_code: "bad_verification" } do
        controller.send(:handle_bound_cookie_refresh)
      end

      rendered = controller.instance_variable_get(:@_test_rendered)

      assert_equal :unprocessable_content, rendered[:status]
      assert_equal "bad_verification", rendered[:json][:error_code]

      controller = build_controller(
        config[:klass],
        headers: { config[:session_header] => %("session-abc"), config[:proof_header] => "proof" },
      )
      controller.define_singleton_method(:dbsc_token_record) {
        record
      } if controller.respond_to?(:dbsc_token_record, true)
      controller.define_singleton_method(:current_preference_record) {
        record
      } if controller.respond_to?(:current_preference_record, true)
      controller.define_singleton_method(config[:url_helper]) { "https://example.test/dbsc" }
      controller.define_singleton_method(config[:cookie_expiry]) { |_value| 1.hour.from_now }

      cookie_args = nil
      controller.define_singleton_method(config[:cookie_setter]) do |session_id, expires_at:|
        cookie_args = { session_id:, expires_at: }
      end

      config[:verification_service].stub :call, { ok: true } do
        controller.send(:handle_bound_cookie_refresh)
      end

      assert_equal({ dbsc_challenge: nil, dbsc_challenge_issued_at: nil }, record.updated_attributes)
      assert_equal "session-abc", cookie_args[:session_id]
      assert_equal :no_content, controller.instance_variable_get(:@_test_head_status)
    end

    test "#{config[:klass].name} returns unauthorized when no bound record exists" do
      controller = build_controller(config[:klass], headers: { config[:session_header] => %("session-abc") })
      controller.define_singleton_method(:dbsc_token_record) { nil } if controller.respond_to?(:dbsc_token_record, true)
      controller.define_singleton_method(:current_preference_record) {
        nil
      } if controller.respond_to?(:current_preference_record, true)

      controller.send(:handle_bound_cookie_refresh)

      assert_equal :unauthorized, controller.instance_variable_get(:@_test_head_status)
    end
  end

  test "auth dbsc token_from_refresh_cookie returns nil when parsing fails" do
    controller = build_controller(Sign::App::Edge::V0::Token::DbscRegistrationsController)
    controller.cookies[Auth::Base::REFRESH_COOKIE_KEY] = "bad-refresh-token"
    token_class =
      Class.new do
        define_singleton_method(:parse_refresh_token) do |_token|
          raise StandardError, "bad token"
        end
      end
    controller.define_singleton_method(:token_class) { token_class }

    assert_nil controller.send(:token_from_refresh_cookie)
  end

  private

  def build_controller(klass, headers: {}, base_url: "https://example.test", host: "example.test")
    controller = klass.new
    request = FakeRequest.new(headers: headers.with_indifferent_access, base_url: base_url, host: host)
    response = FakeResponse.new
    cookies = {}.with_indifferent_access

    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:response) { response }
    controller.define_singleton_method(:cookies) { cookies }
    controller.define_singleton_method(:render) do |**kwargs|
      @_test_rendered = kwargs
    end
    controller.define_singleton_method(:head) do |status|
      @_test_head_status = status
    end

    controller
  end
end
