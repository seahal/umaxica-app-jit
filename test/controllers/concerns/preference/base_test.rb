# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceSanitizeTestController < ::Core::App::ApplicationController
  include ::Preference::Base

  attr_accessor :test_params, :test_controller_path

  def initialize(*)
    super
    @test_params = {}
  end

  def controller_path
    @test_controller_path || "core/app/preferences"
  end

  def params
    @test_params.with_indifferent_access
  end

  def test_sanitize_option_id(params_hash, option_type:)
    sanitize_option_id(params_hash.dup.with_indifferent_access, option_type: option_type)
  end

  def test_ensure_preference_reference_defaults!
    send(:ensure_preference_reference_defaults!)
  end
end

module Preference
  class BaseTest < ActiveSupport::TestCase
    test "preference cookie key constants are stable" do
      assert_equal "ct", Preference::Base::THEME_COOKIE_KEY
      assert_equal "language", Preference::Base::LANGUAGE_COOKIE_KEY
      assert_equal "tz", Preference::Base::TIMEZONE_COOKIE_KEY
    end
  end

  class SanitizeOptionIdTest < ActionDispatch::IntegrationTest
    setup do
      @controller = PreferenceSanitizeTestController.new
    end

    test "returns integer option_id as-is" do
      result = @controller.test_sanitize_option_id({ option_id: 1 }, option_type: :timezone)

      assert_equal 1, result[:option_id]
    end

    test "converts numeric string to integer" do
      result = @controller.test_sanitize_option_id({ option_id: "2" }, option_type: :timezone)

      assert_equal 2, result[:option_id]
    end

    test "resolves valid timezone constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "ASIA_TOKYO" }, option_type: :timezone)

      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "resolves valid timezone with slash notation" do
      result = @controller.test_sanitize_option_id({ option_id: "Asia/Tokyo" }, option_type: :timezone)

      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "resolves valid language constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "JA" }, option_type: :language)

      assert_equal AppPreferenceLanguageOption::JA, result[:option_id]
    end

    test "resolves valid region constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "JP" }, option_type: :region)

      assert_equal AppPreferenceRegionOption::JP, result[:option_id]
    end

    test "resolves valid colortheme constant name" do
      result = @controller.test_sanitize_option_id({ option_id: "dark" }, option_type: :colortheme)

      assert_equal AppPreferenceColorthemeOption::DARK, result[:option_id]
    end

    test "ignores invalid constant name - returns unchanged" do
      result = @controller.test_sanitize_option_id({ option_id: "INVALID_CONST" }, option_type: :timezone)

      assert_equal "INVALID_CONST", result[:option_id]
    end

    test "ignores malicious input attempting to access arbitrary constant" do
      malicious_inputs = %w(
        RAILS_ENV
        SECRET_KEY_BASE
        ApplicationController
        Object
        Kernel
      )

      malicious_inputs.each do |input|
        result = @controller.test_sanitize_option_id({ option_id: input }, option_type: :timezone)

        assert_equal input, result[:option_id], "Expected malicious input '#{input}' to be returned unchanged"
      end
    end

    test "handles nil option_id" do
      result = @controller.test_sanitize_option_id({ option_id: nil }, option_type: :timezone)

      assert_nil result[:option_id]
    end

    test "handles empty string option_id" do
      result = @controller.test_sanitize_option_id({ option_id: "" }, option_type: :timezone)

      assert_nil result[:option_id]
    end

    test "normalizes lowercase input" do
      result = @controller.test_sanitize_option_id({ option_id: "asia_tokyo" }, option_type: :timezone)

      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end

    test "normalizes hyphenated input" do
      result = @controller.test_sanitize_option_id({ option_id: "asia-tokyo" }, option_type: :timezone)

      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO, result[:option_id]
    end
  end

  class EnsureReferenceDefaultsTest < ActiveSupport::TestCase
    setup do
      @controller = PreferenceSanitizeTestController.new
    end

    test "recreates missing app preference activity level defaults" do
      AppPreferenceActivity.delete_all
      AppPreferenceActivityLevel.where(id: AppPreferenceActivityLevel::INFO).delete_all

      assert_nil AppPreferenceActivityLevel.find_by(id: AppPreferenceActivityLevel::INFO)

      @controller.test_ensure_preference_reference_defaults!

      assert_not_nil AppPreferenceActivityLevel.find_by(id: AppPreferenceActivityLevel::INFO)
    end

    test "recreates missing org preference activity level defaults on the activity writer" do
      @controller.test_controller_path = "core/org/preferences"
      OrgPreferenceActivity.delete_all
      OrgPreferenceActivityLevel.where(id: OrgPreferenceActivityLevel::INFO).delete_all

      assert_nil OrgPreferenceActivityLevel.find_by(id: OrgPreferenceActivityLevel::INFO)

      @controller.test_ensure_preference_reference_defaults!

      assert_not_nil OrgPreferenceActivityLevel.find_by(id: OrgPreferenceActivityLevel::INFO)
    end
  end

  class JwtConfigurationTest < ActiveSupport::TestCase
    test "active_kid returns value from ENV" do
      with_env("PREFERENCE_JWT_ACTIVE_KID" => "test_kid") do
        assert_equal "test_kid", Preference::JwtConfiguration.active_kid
      end
    end

    test "leeway_seconds returns value from ENV" do
      with_env("PREFERENCE_JWT_LEEWAY_SECONDS" => "45") do
        assert_equal 45, Preference::JwtConfiguration.leeway_seconds
      end
    end

    test "issuer returns value from ENV" do
      with_env("PREFERENCE_JWT_ISSUER" => "test-issuer") do
        assert_equal "test-issuer", Preference::JwtConfiguration.issuer
      end
    end

    test "audiences returns split values from ENV" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "aud1, aud2 , aud3") do
        assert_equal %w(aud1 aud2 aud3), Preference::JwtConfiguration.audiences
      end
    end

    test "audience_for filters to matching TLD only" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "umaxica.app,umaxica.com,localhost") do
        result = Preference::JwtConfiguration.audience_for("sign.umaxica.app")

        assert_includes result, "umaxica.app"
        assert_includes result, "localhost", "localhost is included in non-production"
        assert_not_includes result, "umaxica.com"
      end
    end

    test "audience_for returns only matching TLD for com host" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "umaxica.app,umaxica.com,localhost") do
        result = Preference::JwtConfiguration.audience_for("ww.umaxica.com")

        assert_includes result, "umaxica.com"
        assert_includes result, "localhost"
        assert_not_includes result, "umaxica.app"
      end
    end

    test "audience_for includes localhost for localhost host" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "umaxica.app,umaxica.com,localhost") do
        result = Preference::JwtConfiguration.audience_for("sign.app.localhost")

        assert_includes result, "localhost"
        assert_not_includes result, "umaxica.app"
        assert_not_includes result, "umaxica.com"
      end
    end

    test "audience_for returns all audiences when host is blank" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "umaxica.app,umaxica.com") do
        result = Preference::JwtConfiguration.audience_for("")

        assert_equal %w(umaxica.app umaxica.com), result
      end
    end

    test "audience_for falls back to all audiences when no TLD matches" do
      with_env("PREFERENCE_JWT_AUDIENCES" => "umaxica.app,umaxica.com") do
        result = Preference::JwtConfiguration.audience_for("example.org")

        assert_equal %w(umaxica.app umaxica.com), result
      end
    end

    test "parse_header decodes token header" do
      token = JWT.encode({ foo: "bar" }, nil, "none", { kid: "test_kid" })
      header = Preference::JwtConfiguration.parse_header(token)

      assert_equal "test_kid", header["kid"]
    end

    private

    def with_env(vars)
      original = vars.keys.index_with { |k| ENV[k] }
      vars.each { |k, v| ENV[k] = v }
      yield
    ensure
      original.each { |k, v| ENV[k] = v }
    end
  end

  class TokenTest < ActiveSupport::TestCase
    setup do
      @preferences = { "theme" => "dark" }.freeze
      @host = "app.localhost"
      @type = "user"
      @public_id = "test_id"
      @jti = "test_jti"

      # Generate a test EC key
      @key = OpenSSL::PKey::EC.generate("secp384r1")
      @der = Base64.encode64(@key.to_der)
      @pub_der = Base64.encode64(@key.public_to_der)
    end

    test "encode and decode a valid token" do
      Preference::JwtConfiguration.stub(:private_key_for_active, @key) do
        Preference::JwtConfiguration.stub(:public_key_for, @key) do
          Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
            token = Preference::Token.encode(
              @preferences,
              host: @host,
              preference_type: @type,
              public_id: @public_id,
              jti: @jti,
            )

            assert_not_nil token

            decoded = Preference::Token.decode(token, host: @host)

            assert_not_nil decoded
            assert_equal @preferences, decoded["preferences"]
            assert_equal @host, decoded["host"]
            assert_equal @type, decoded["preference_type"]
            assert_equal @public_id, decoded["public_id"]
            assert_equal @jti, decoded["jti"]
          end
        end
      end
    end

    test "decode returns nil for invalid host" do
      Preference::JwtConfiguration.stub(:private_key_for_active, @key) do
        Preference::JwtConfiguration.stub(:public_key_for, @key) do
          Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
            token = Preference::Token.encode(
              @preferences,
              host: @host,
              preference_type: @type,
              public_id: @public_id,
              jti: @jti,
            )

            assert_nil Preference::Token.decode(token, host: "wrong.host")
          end
        end
      end
    end

    test "extract_preferences returns preferences from payload" do
      payload = { "preferences" => { "theme" => "light" } }

      assert_equal({ "theme" => "light" }, Preference::Token.extract_preferences(payload))
      assert_equal({}, Preference::Token.extract_preferences(nil))
    end
  end

  class PreferenceBaseMethodsTest < ActiveSupport::TestCase
    setup do
      @controller = PreferenceSanitizeTestController.new
    end

    test "resolve_option_id_from_param returns default for blank value" do
      assert_equal 99, @controller.send(:resolve_option_id_from_param, nil, :timezone, 99, "prefix")
      assert_equal 99, @controller.send(:resolve_option_id_from_param, "", :timezone, 99, "prefix")
    end

    test "resolve_option_id_from_param returns integer for valid input" do
      assert_equal AppPreferenceTimezoneOption::ASIA_TOKYO,
                   @controller.send(:resolve_option_id_from_param, "Asia/Tokyo", :timezone, 99, "prefix")
    end

    test "normalized_locale returns sym for valid locale" do
      I18n.stub(:available_locales, [:en, :ja]) do
        assert_equal :en, @controller.send(:normalized_locale, "en")
        assert_equal :ja, @controller.send(:normalized_locale, "JA")
        assert_nil @controller.send(:normalized_locale, "invalid")
        assert_nil @controller.send(:normalized_locale, "")
      end
    end

    test "locale_from_region returns mapped locale" do
      assert_equal "ja", @controller.send(:locale_from_region, "jp")
      assert_equal "en", @controller.send(:locale_from_region, "us")
      assert_nil @controller.send(:locale_from_region, "unknown")
    end

    test "available_locale_strings returns unique lowercased strings" do
      I18n.stub(:available_locales, %i(en JA en)) do
        # Clear memoized value
        @controller.instance_variable_set(:@available_locale_strings, nil)

        assert_equal %w(en ja), @controller.send(:available_locale_strings)
      end
    end

    test "host_matches? handles direct and subdomain matches" do
      # Since host_matches? is in Preference::Token (which is a class)
      # Wait, I see host_matches? in Preference::Token class << self
      assert Preference::Token.send(:host_matches?, "example.com", "example.com")
      assert Preference::Token.send(:host_matches?, "example.com", "sub.example.com")
      assert_not Preference::Token.send(:host_matches?, "example.com", "other.com")
      assert_not Preference::Token.send(:host_matches?, nil, "example.com")
    end

    test "audience_matches? handles multiple audiences" do
      assert Preference::Token.send(:audience_matches?, ["a.com", "b.com"], "a.com")
      assert Preference::Token.send(:audience_matches?, ["a.com", "b.com"], "sub.b.com")
      assert_not Preference::Token.send(:audience_matches?, ["a.com", "b.com"], "c.com")
    end
  end

  class BuildPreferencesPayloadTest < ActiveSupport::TestCase
    FakeCookie = Struct.new(:consented, :functional, :performant, :targetable, keyword_init: true)
    FakePreference =
      Struct.new(
        :app_preference_language, :app_preference_region, :app_preference_timezone,
        :app_preference_colortheme, :app_preference_cookie, keyword_init: true,
      ) do
        def class
          AppPreference
        end
      end

    setup do
      @controller = PreferenceSanitizeTestController.new
    end

    test "build_preferences_payload includes consent categories from cookie record" do
      cookie = FakeCookie.new(consented: true, functional: true, performant: false, targetable: false)
      preference = FakePreference.new(app_preference_cookie: cookie)

      payload = @controller.send(:build_preferences_payload, preference)

      assert payload["consented"]
      assert payload["functional"]
      assert_not payload["performant"]
      assert_not payload["targetable"]
      assert_equal "ja", payload["lx"]
      assert_equal "jp", payload["ri"]
      assert_equal "Asia/Tokyo", payload["tz"]
      assert_equal "sy", payload["ct"]
    end

    test "build_preferences_payload defaults consent to false when cookie is nil" do
      preference = FakePreference.new(app_preference_cookie: nil)

      payload = @controller.send(:build_preferences_payload, preference)

      assert_not payload["consented"]
      assert_not payload["functional"]
      assert_not payload["performant"]
      assert_not payload["targetable"]
    end

    test "build_preferences_payload does not include legacy consent key" do
      preference = FakePreference.new(app_preference_cookie: nil)

      payload = @controller.send(:build_preferences_payload, preference)

      assert_not payload.key?("consent"), "legacy 'consent' key should no longer be present"
    end
  end
end
