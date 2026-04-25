# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceSanitizeTestController < Sign::App::ApplicationController
  include ::Preference::Base

  attr_accessor :test_params, :test_controller_path

  def initialize(*)
    super
    @test_params = {}
  end

  def controller_path
    @test_controller_path || "base/app/preferences"
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

  class CreateNewPreferenceWithStorageAdapterTest < ActiveSupport::TestCase
    setup do
      @controller = PreferenceSanitizeTestController.new
      @controller.request = ActionDispatch::TestRequest.create
      @controller.response = ActionDispatch::TestResponse.new
      @controller.define_singleton_method(:generate_refresh_token) do |public_id:|
        _ = public_id
        ["generated-token", "generated-verifier"]
      end
      @controller.define_singleton_method(:digest_refresh_token) do |_verifier|
        "token-digest"
      end
      @controller.define_singleton_method(:create_preference_options_for_setting) do |_wrapper, _params_hash|
        nil
      end
      @controller.define_singleton_method(:create_audit_log) do |**_kwargs|
        nil
      end
      @controller.define_singleton_method(:set_refresh_token_cookie) do |_token, _expires_at|
        nil
      end
      @controller.define_singleton_method(:set_preference_dbsc_cookie!) do |_token, expires_at:|
        _ = expires_at
        nil
      end
      @controller.define_singleton_method(:set_preference_device_id_cookie!) do |_device_id, expires_at:|
        _ = expires_at
        nil
      end
      @controller.define_singleton_method(:issue_preference_dbsc_registration_header_for) do |_preference|
        nil
      end
    end

    test "works in readonly mode" do
      SettingRecord.connected_to(role: :reading) do
        assert_difference("SettingPreference.count", 1) do
          @controller.send(:create_new_preference_with_storage_adapter!, 1.day.from_now, "device-123")
        end
      end
    end

    test "create_preference_options_for_setting reuses existing child records" do
      preference = SettingPreference.create!(
        owner_type: "Customer",
        owner_id: 0,
        jti: SecureRandom.uuid,
      )
      wrapper = Preference::StorageAdapter::PreferenceWrapper.new(
        preference: preference,
        source: :setting,
        preference_type: "ComPreference",
      )

      @controller.send(:create_preference_options_for_setting, wrapper, { ri: "jp" })

      assert_no_difference("SettingPreferenceCookie.count") do
        assert_no_difference("SettingPreferenceLanguage.count") do
          assert_no_difference("SettingPreferenceRegion.count") do
            assert_no_difference("SettingPreferenceTimezone.count") do
              assert_no_difference("SettingPreferenceColortheme.count") do
                @controller.send(:create_preference_options_for_setting, wrapper, { ri: "jp" })
              end
            end
          end
        end
      end
    end

    test "create_new_preference_with_storage_adapter! is idempotent for the same anonymous owner" do
      first = @controller.send(:create_new_preference_with_storage_adapter!, 1.day.from_now, "device-123")

      second = @controller.send(:create_new_preference_with_storage_adapter!, 1.day.from_now, "device-123")

      assert_equal first.public_id, second.public_id
      assert_equal first.id, second.id
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

    test "decode rejects HMAC confusion attack with HS384 and public key" do
      Preference::JwtConfiguration.stub(:public_key_for, @key) do
        Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
          hmac_secret = @key.to_pem
          token = JWT.encode(
            { "preferences" => { "theme" => "dark" } },
            hmac_secret, "HS384",
            { "kid" => "test_kid", "typ" => "preference-access-token" },
          )

          assert_nil Preference::Token.decode(token, host: "app.localhost")
        end
      end
    end

    test "decode rejects HMAC confusion attack with HS256 and public key" do
      Preference::JwtConfiguration.stub(:public_key_for, @key) do
        Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
          hmac_secret = @key.to_pem
          token = JWT.encode(
            { "preferences" => { "theme" => "dark" } },
            hmac_secret, "HS256",
            { "kid" => "test_kid", "typ" => "preference-access-token" },
          )

          assert_nil Preference::Token.decode(token, host: "app.localhost")
        end
      end
    end

    test "decode rejects token signed with ES256 algorithm" do
      es256_key = OpenSSL::PKey::EC.generate("prime256v1")
      token = JWT.encode(
        { "preferences" => { "theme" => "dark" } },
        es256_key, "ES256",
        { "kid" => "test_kid", "typ" => "preference-access-token" },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects forged token with injected jwk header" do
      token = forge_jwt_with_header(
        {
          "alg" => "ES384",
          "typ" => "preference-access-token",
          "kid" => Preference::JwtConfiguration.active_kid,
          "jwk" => { "kty" => "EC", "crv" => "P-384" },
          "jku" => "https://attacker.example.com/jwks",
        },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects auth token type used as preference token" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => "test_kid" },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects token with single segment" do
      assert_nil Preference::Token.decode("eyJhbGciOiJFUzM4NCJ9", host: "app.localhost")
    end

    test "decode rejects token with four segments" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "preference-access-token", "kid" => "any" },
        { "preferences" => {} },
      )

      assert_nil Preference::Token.decode("#{token}extra_segment", host: "app.localhost")
    end

    test "decode rejects forged token with correct alg ES384 but unknown kid" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "preference-access-token", "kid" => "forged-kid" },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects forged token with correct alg ES384 and valid kid but invalid signature" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "preference-access-token", "kid" => Preference::JwtConfiguration.active_kid },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    # -- Cross-audience replay test --

    test "decode rejects preference token from different audience domain" do
      Preference::JwtConfiguration.stub(:private_key_for_active, @key) do
        Preference::JwtConfiguration.stub(:public_key_for, @key) do
          Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
            token = Preference::Token.encode(
              @preferences,
              host: "org.localhost",
              preference_type: @type,
              public_id: @public_id,
              jti: @jti,
            )

            assert_nil Preference::Token.decode(token, host: "app.localhost")
          end
        end
      end
    end

    # -- Expired / timing boundary tests --

    test "decode rejects token expired beyond leeway" do
      Preference::JwtConfiguration.stub(:private_key_for_active, @key) do
        Preference::JwtConfiguration.stub(:public_key_for, @key) do
          Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
            now = Time.current.to_i
            payload = {
              preferences: @preferences,
              host: @host,
              preference_type: @type,
              public_id: @public_id,
              jti: @jti,
              typ: "preference-access-token",
              iss: Preference::JwtConfiguration.issuer,
              aud: Preference::JwtConfiguration.audience_for(@host),
              iat: now - 600,
              exp: now - 31,
            }
            token = JWT.encode(payload, @key, "ES384", { kid: "test_kid", typ: "preference-access-token" })

            assert_nil Preference::Token.decode(token, host: @host)
          end
        end
      end
    end

    test "decode rejects token with future iat beyond leeway" do
      Preference::JwtConfiguration.stub(:private_key_for_active, @key) do
        Preference::JwtConfiguration.stub(:public_key_for, @key) do
          Preference::JwtConfiguration.stub(:active_kid, "test_kid") do
            now = Time.current.to_i
            payload = {
              preferences: @preferences,
              host: @host,
              preference_type: @type,
              public_id: @public_id,
              jti: @jti,
              typ: "preference-access-token",
              iss: Preference::JwtConfiguration.issuer,
              aud: Preference::JwtConfiguration.audience_for(@host),
              iat: now + 300,
              exp: now + 900,
            }
            token = JWT.encode(payload, @key, "ES384", { kid: "test_kid", typ: "preference-access-token" })

            assert_nil Preference::Token.decode(token, host: @host)
          end
        end
      end
    end

    # -- kid injection tests --

    test "decode rejects token with SQL injection in kid" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "preference-access-token", "kid" => "' OR 1=1 --" },
        { "preferences" => {} },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects token with path traversal in kid" do
      token = forge_jwt_with_header(
        { "alg" => "ES384", "typ" => "preference-access-token", "kid" => "../../etc/passwd" },
        { "preferences" => {} },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    # -- Malformed token tests --

    test "decode rejects token containing null bytes" do
      assert_nil Preference::Token.decode("eyJ\x00hbGci.eyJz\x00dWIi.sig", host: "app.localhost")
    end

    test "decode rejects extremely long token" do
      assert_nil Preference::Token.decode("a" * 100_000, host: "app.localhost")
    end

    test "decode rejects token with unicode in segments" do
      assert_nil Preference::Token.decode("eyJhbGci\u00e9.eyJzdWIi.sig", host: "app.localhost")
    end

    test "decode rejects token with alg none header" do
      token = forge_jwt_with_header(
        { "alg" => "none", "typ" => "preference-access-token", "kid" => "any" },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects token with alg empty string header" do
      token = forge_jwt_with_header(
        { "alg" => "", "typ" => "preference-access-token", "kid" => "any" },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "decode rejects token with alg nil header" do
      token = forge_jwt_with_header(
        { "alg" => nil, "typ" => "preference-access-token", "kid" => "any" },
        { "preferences" => { "theme" => "dark" } },
      )

      assert_nil Preference::Token.decode(token, host: "app.localhost")
    end

    test "extract_preferences returns preferences from payload" do
      payload = { "preferences" => { "theme" => "light" } }

      assert_equal({ "theme" => "light" }, Preference::Token.extract_preferences(payload))
      assert_equal({}, Preference::Token.extract_preferences(nil))
    end

    private

    def forge_jwt_with_header(header_hash, payload_hash)
      header = Base64.urlsafe_encode64(JSON.generate(header_hash), padding: false)
      payload = Base64.urlsafe_encode64(JSON.generate(payload_hash), padding: false)
      "#{header}.#{payload}."
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
