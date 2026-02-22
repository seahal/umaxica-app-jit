# frozen_string_literal: true

require "jwt"
require "sha3"
require "concurrent"

module Preference
  # ==========================================================================
  # TOC (approximate)
  # 1) JWT configuration & token primitives ........................... L8-L168
  # 2) Preference request entrypoints (I/O boundary) .................. L170-L240
  # 3) Preference option/domain mapping ............................... L240-L406
  # 4) Audit + preference domain updates .............................. L409-L530
  # 5) Refresh/access token lifecycle (I/O + domain) ................. L533-L895
  # 6) Cookie/header/session helpers (I/O boundary) ................... L897-L985
  # 7) Child-record lazy helpers ...................................... L985-L1005
  # ==========================================================================

  # ==========================================================================
  # 1) JWT configuration & token primitives
  # ==========================================================================
  module JwtConfiguration
    EPHEMERAL_PRIVATE_KEY_MUTEX = Mutex.new
    EPHEMERAL_PRIVATE_KEY_CACHE = Concurrent::AtomicReference.new(nil)

    def self.issuer
      ENV.fetch("PREFERENCE_JWT_ISSUER", "jit-preference")
    end

    def self.audiences
      raw = ENV["PREFERENCE_JWT_AUDIENCES"].to_s
      audiences = raw.split(",").map(&:strip)
      audiences.reject!(&:empty?)
      audiences
    end

    def self.private_key
      private_key_base64 = ENV["PREFERENCE_JWT_PRIVATE_KEY"] ||
        Rails.application.credentials.dig(:JWT, :PREFERENCE, :PRIVATE_KEY)
      if private_key_base64.blank?
        return ephemeral_private_key unless Rails.env.production?

        raise "Preference JWT private key not configured in credentials"
      end

      private_key_der = Base64.decode64(private_key_base64)
      OpenSSL::PKey::EC.new(private_key_der)
    end

    def self.public_key
      public_key_base64 = ENV["PREFERENCE_JWT_PUBLIC_KEY"] ||
        Rails.application.credentials.dig(:JWT, :PREFERENCE, :PUBLIC_KEY)
      if public_key_base64.blank?
        return ephemeral_private_key.public_key unless Rails.env.production?

        raise "Preference JWT public key not configured in credentials"
      end

      public_key_der = Base64.decode64(public_key_base64)
      OpenSSL::PKey::EC.new(public_key_der)
    end

    def self.ephemeral_private_key
      cached_key = EPHEMERAL_PRIVATE_KEY_CACHE.get
      return cached_key if cached_key

      EPHEMERAL_PRIVATE_KEY_MUTEX.synchronize do
        EPHEMERAL_PRIVATE_KEY_CACHE.get ||
          EPHEMERAL_PRIVATE_KEY_CACHE.set(OpenSSL::PKey::EC.generate("secp384r1"))
      end
    end
  end

  class Token
    JWT_ALGORITHM = "ES384"
    ACCESS_TOKEN_TTL = 7.days

    class << self
      def encode(preferences, host:, preference_type:, public_id:, jti:)
        return nil unless valid_encode_params?(preferences, host, preference_type, public_id, jti)

        payload = build_payload(preferences, host, preference_type, public_id, jti)
        JWT.encode(payload, JwtConfiguration.private_key, JWT_ALGORITHM)
      rescue StandardError => error
        Rails.logger.error("PreferenceToken.encode failed: #{error.message}")
        nil
      end

      def decode(token, host:)
        return nil if token.blank? || host.blank?

        payload, = JWT.decode(token, JwtConfiguration.public_key, true, decode_options)
        validate_payload(payload, host)
      rescue JWT::ExpiredSignature
        Rails.logger.debug("PreferenceToken.decode failed: token expired")
        nil
      rescue JWT::DecodeError => error
        Rails.logger.debug { "PreferenceToken.decode invalid token: #{error.message}" }
        nil
      rescue StandardError => error
        Rails.logger.error("PreferenceToken.decode failed: #{error.message}")
        nil
      end

      def extract_preferences(payload)
        return {} unless payload.is_a?(Hash)

        payload["preferences"] || {}
      end

      def extract_public_id(payload)
        payload&.dig("public_id")
      end

      def extract_preference_type(payload)
        payload&.dig("preference_type")
      end

      def extract_jti(payload)
        payload&.dig("jti")
      end

      private

      def valid_encode_params?(preferences, host, preference_type, public_id, jti)
        [preferences, host, preference_type, public_id, jti].all?(&:present?)
      end

      def build_payload(preferences, host, preference_type, public_id, jti)
        now = Time.current.to_i
        {
          preferences: preferences,
          host: host,
          preference_type: preference_type,
          public_id: public_id,
          jti: jti,
          iss: JwtConfiguration.issuer,
          aud: JwtConfiguration.audiences,
          nonce: SecureRandom.uuid,
          iat: now,
          exp: now + ACCESS_TOKEN_TTL.to_i,
        }
      end

      def decode_options
        {
          algorithm: JWT_ALGORITHM,
          verify_iss: true,
          iss: JwtConfiguration.issuer,
          verify_aud: false,
          verify_iat: true,
        }
      end

      def validate_payload(payload, host)
        return nil unless payload.is_a?(Hash)
        return nil unless host_matches?(payload["host"], host)
        return nil unless audience_matches?(payload["aud"], host)

        payload
      end

      def host_matches?(host_claim, host)
        return false if host_claim.blank?

        host == host_claim || host.end_with?(".#{host_claim}")
      end

      def audience_matches?(aud_claim, host)
        normalize_audiences(aud_claim).any? do |aud|
          host == aud || host.end_with?(".#{aud}")
        end
      end

      def normalize_audiences(aud_claim)
        case aud_claim
        when Array then aud_claim
        when String then [aud_claim]
        else []
        end
      end
    end
  end

  module Base
    extend ActiveSupport::Concern
    include RefreshTokenShared

    ACCESS_TOKEN_TTL = 7.days
    REFRESH_TOKEN_TTL = 400.days
    THEME_COOKIE_KEY = Preference::IoKeys::Cookies::THEME
    LEGACY_THEME_COOKIE_KEY = Preference::IoKeys::Cookies::LEGACY_THEME
    LANGUAGE_COOKIE_KEY = Preference::IoKeys::Cookies::LANGUAGE
    TIMEZONE_COOKIE_KEY = Preference::IoKeys::Cookies::TIMEZONE

    COLORTHEME_SHORT_MAP = {
      "light" => "li",
      "dark" => "dr",
      "system" => "sy",
    }.freeze

    COLORTHEME_OPTION_MAP = {
      "li" => "light",
      "dr" => "dark",
      "sy" => "system",
      "light" => "light",
      "dark" => "dark",
      "system" => "system",
    }.freeze

    included do
      before_action :set_preferences_cookie
    end

    private

    # ==========================================================================
    # 2) Preference request entrypoints (Request/Cookie I/O boundary)
    # ==========================================================================
    def set_preferences_cookie
      clear_preference_refresh_failure!
      return if load_access_token_payload

      preference, _ = load_preference_record_from_refresh_token!(create_if_missing: true)
      return render_preference_refresh_error! if preference_refresh_failed?
      return if preference.blank?

      # Rotate refresh token on access token re-issue to limit replay if leaked.
      refresh_refresh_token_lifetime(preference)
      return render_preference_refresh_error! if preference_refresh_failed?

      issue_access_token_from(@preferences || preference)
      nil
    end

    def set_color_theme
      theme = normalize_colortheme(params[Preference::IoKeys::Params::CT].presence)
      theme ||= normalize_colortheme(cookies[THEME_COOKIE_KEY])
      theme ||= normalize_colortheme(cookies[LEGACY_THEME_COOKIE_KEY])
      theme ||= normalize_colortheme(preference_payload_value("ct"))
      if theme.blank? && @preferences.present?
        option_id = @preferences.public_send(preference_colortheme_association)&.option_id
        theme = colortheme_short_code(option_id_to_colortheme(option_id, preference_prefix))
      end
      # Rails must not trust this value; use jit_preference_access instead.
      # However, for theme, we allow cookie to override stored preference to support local toggling/anonymous.
      theme ||= "sy"

      write_preference_cookie(THEME_COOKIE_KEY, theme)
      @color_theme = theme
      nil
    end

    def create_preference_options(preference, params_hash = {})
      prefix = preference_prefix(preference)
      option_ids = preference_option_ids(prefix, params_hash)

      create_preference_cookie(prefix, preference)
      ensure_preference_option_defaults(prefix)
      create_preference_option_records(prefix, preference, option_ids)
    end

    # ==========================================================================
    # 3) Preference option/domain mapping
    # ==========================================================================
    def preference_option_ids(prefix, params_hash)
      option_classes = preference_option_classes(prefix)

      {
        timezone: resolve_option_id_from_param(
          params_hash[:tz],
          :timezone,
          option_classes[:timezone]::ASIA_TOKYO,
          prefix,
        ),
        language: resolve_option_id_from_param(
          params_hash[:lx],
          :language,
          option_classes[:language]::JA,
          prefix,
        ),
        region: resolve_option_id_from_param(
          params_hash[:ri],
          :region,
          option_classes[:region]::JP,
          prefix,
        ),
        colortheme: resolve_option_id_from_param(
          params_hash[:ct],
          :colortheme,
          option_classes[:colortheme]::SYSTEM,
          prefix,
        ),
      }
    end

    def preference_option_classes(prefix)
      {
        timezone: Preference::ClassRegistry.option_class(prefix, :timezone),
        language: Preference::ClassRegistry.option_class(prefix, :language),
        region: Preference::ClassRegistry.option_class(prefix, :region),
        colortheme: Preference::ClassRegistry.option_class(prefix, :colortheme),
      }
    end

    def create_preference_cookie(prefix, preference)
      Preference::ClassRegistry.cookie_class(prefix).create!(
        preference_id: preference.id,
        targetable: false,
        performant: false,
        functional: false,
        consented: false,
      )
    end

    def ensure_preference_option_defaults(prefix)
      %w(Timezone Language Region Colortheme).each do |type|
        klass = Preference::ClassRegistry.option_class(prefix, type)
        klass.ensure_defaults! if klass.respond_to?(:ensure_defaults!)
      end
    end

    def create_preference_option_records(prefix, preference, option_ids)
      %w(Timezone Language Region Colortheme).each do |type|
        Preference::ClassRegistry.record_class(prefix, type).create!(
          preference_id: preference.id,
          option_id: option_ids[type.downcase.to_sym],
        )
      end
    end

    def resolve_option_id_from_param(value, type, default, _prefix)
      return default if value.blank?

      sanitized = sanitize_option_id({ option_id: value }, option_type: type)
      if sanitized[:option_id].is_a?(Integer)
        sanitized[:option_id]
      else
        default
      end
    end

    def write_preference_cookie(key, value)
      cookies[key] = preference_cookie_options(expires_at: REFRESH_TOKEN_TTL.from_now, httponly: false).merge(
        value: value,
      )
    end

    def set_locale_from_params
      locale = normalized_locale(params[Preference::IoKeys::Params::LX])
      locale ||= normalized_locale(cookies[LANGUAGE_COOKIE_KEY])
      locale ||= normalized_locale(preference_payload_value("lx"))
      locale ||= locale_from_region(params[Preference::IoKeys::Params::RI])
      locale ||= locale_from_region(preference_payload_value("ri"))
      locale ||= I18n.default_locale

      I18n.locale = locale
    end

    def locale_from_region(region)
      return if region.blank?

      {
        "jp" => "ja",
        "us" => "en",
      }[region]
    end

    def normalized_locale(value)
      return if value.blank?

      normalized_value = value.to_s.downcase
      return if normalized_value.blank?

      if available_locale_strings.include?(normalized_value)
        normalized_value.to_sym
      end
    end

    def available_locale_strings
      @available_locale_strings ||=
        begin
          locales = I18n.available_locales.map { |locale| locale.to_s.downcase }
          locales.uniq!
          locales
        end
    end

    def set_timezone_from_session
      Time.zone = session[:timezone] if session[:timezone].present?
    end

    def preference_class
      @preference_class ||=
        begin
          Preference::ClassRegistry.for_controller_path(controller_path)
        end
    end

    def preference_audit_class
      @preference_audit_class ||= Preference::ClassRegistry.audit_class_for(preference_class)
    end

    def preference_audit_event_class
      @preference_audit_event_class ||= Preference::ClassRegistry.audit_event_class_for(preference_class)
    end

    def preference_audit_level_class
      @preference_audit_level_class ||= Preference::ClassRegistry.audit_level_class_for(preference_class)
    end

    def preference_status_class
      @preference_status_class ||= Preference::ClassRegistry.status_class_for(preference_class)
    end

    # ==========================================================================
    # 4) Audit + preference domain updates
    # ==========================================================================
    def normalize_preference_audit_event_id(event_id)
      return if event_id.blank?
      return event_id if event_id.is_a?(Integer)

      if preference_audit_event_class.const_defined?(event_id)
        preference_audit_event_class.const_get(event_id)
      else
        event_id
      end
    end

    def ensure_preferences_record
      load_preference_record_from_refresh_token!(create_if_missing: true)
    end

    def create_audit_log(event_id:, context:, expires_at: nil)
      expires_at_value = expires_at || REFRESH_TOKEN_TTL.from_now
      normalized_event_id = normalize_preference_audit_event_id(event_id)

      ActivityRecord.connected_to(role: :writing) do
        if normalized_event_id.present?
          preference_audit_event_class.find_or_create_by!(id: normalized_event_id)
        end

        preference_audit_class.create!(
          subject_id: @preferences.id.to_s,
          subject_type: @preferences.class.name,
          event_id: normalized_event_id,
          level_id: preference_audit_level_class::INFO,
          occurred_at: Time.current,
          expires_at: expires_at_value,
          ip_address: request.remote_ip || "0.0.0.0",
          context: context,
        )
      end
    end

    def preference_prefix(preference = nil)
      return preference.class.name.gsub("Preference", "") if preference.present?

      @preference_prefix ||= preference_class.name.gsub("Preference", "")
    end

    def preference_prefix_underscore
      @preference_prefix_underscore ||= preference_class.name.underscore
    end

    def preference_colortheme_association
      @preference_colortheme_association ||= "#{preference_prefix_underscore}_colortheme"
    end

    def update_preference_child_with_audit(child, attributes, audit_event)
      return if child.blank? || attributes.blank?

      # Ensure nested params are a Hash with indifferent access for reliable key access.
      # Note: Rails 8 `expect` returns an ActionController::Parameters object,
      # which we want to convert to Hash with indifferent access after ensuring it's permitted.
      p_hash = attributes.to_h.with_indifferent_access

      PreferenceRecord.transaction do
        child.update!(p_hash)
        create_audit_log(
          event_id: audit_event,
          context: { updated_attributes: p_hash },
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("#{audit_event} failed: #{e.message}")
      raise PreferenceOperationError
    end

    def sanitize_option_id(params, option_type: nil)
      params[Preference::IoKeys::Params::OPTION_ID] = nil if params[Preference::IoKeys::Params::OPTION_ID].blank?

      return params if params[Preference::IoKeys::Params::OPTION_ID].blank?

      # If option_id is already an integer, use it as-is
      option_id_key = Preference::IoKeys::Params::OPTION_ID
      if params[option_id_key].is_a?(Integer) || params[option_id_key].to_s.match?(/^\d+$/)
        params[option_id_key] = params[option_id_key].to_i
        return params
      end

      prefix = preference_class.name.delete_suffix("Preference")
      option_class =
        case option_type
        when :colortheme then Preference::ClassRegistry.option_class(prefix, :colortheme)
        when :language then Preference::ClassRegistry.option_class(prefix, :language)
        when :region then Preference::ClassRegistry.option_class(prefix, :region)
        when :timezone then Preference::ClassRegistry.option_class(prefix, :timezone)
        end

      if option_class
        name =
          if option_type == :colortheme
            canonical_colortheme_option_id(params[option_id_key])
          else
            params[option_id_key]
          end
        if name.present?
          # Try to find constant matching the name (upcase)
          # For Language/Region/Timezone, the input might be "US", "EN", "Asia/Tokyo"
          # We need to map these to constants like US, EN, ASIA_TOKYO
          const_name = name.to_s.upcase.tr("/", "_").tr("-", "_")

          if option_class.const_defined?(const_name)
            params[option_id_key] = option_class.const_get(const_name)
          end
        end
      end
      params
    end

    def canonical_colortheme_option_id(value)
      return nil if value.blank?

      COLORTHEME_OPTION_MAP[value.to_s.downcase]
    end

    def colortheme_short_code(value)
      return nil if value.blank?

      COLORTHEME_SHORT_MAP[value.to_s.downcase]
    end

    def normalize_colortheme(value)
      return nil if value.blank?

      theme = value.to_s.downcase
      if COLORTHEME_SHORT_MAP.value?(theme)
        theme
      else
        COLORTHEME_SHORT_MAP[theme]
      end
    end

    def ensure_preference_status_defaults!
      Preference::ClassRegistry.status_class_for(preference_class).ensure_defaults!
    end

    # ==========================================================================
    # 5) Refresh/access token lifecycle (Cookie/Header/Request I/O boundary)
    # ==========================================================================
    def load_access_token_payload
      token = cookies[access_token_cookie_name]
      return false if token.blank?

      payload = Token.decode(token, host: request.host)
      return false if payload.blank?
      return false if Token.extract_preference_type(payload) != preference_class.name

      @preference_payload = payload

      # Load @preferences if public_id is present in the token
      public_id = Token.extract_public_id(payload)
      if public_id.present?
        @preferences = preference_class.includes(preference_associations_to_preload).find_by(public_id: public_id)
      end

      true
    end

    def load_preference_record_from_refresh_token!(create_if_missing: false)
      return [@preferences, false] if @preferences.present?

      token_value = refresh_token_value
      @refresh_token_value = token_value
      refresh_public_id = nil
      refresh_device_id = nil
      @refresh_presented_digest = nil
      @refresh_public_id = nil
      preference =
        if token_value.present?
          refresh_public_id, refresh_verifier = parse_refresh_token(token_value)
          digest =
            if refresh_verifier.present?
              digest_refresh_token(refresh_verifier)
            else
              refresh_token_lookup_digest(token_value)
            end
          PreferenceRecord.connected_to(role: :writing) do
            relation = preference_class.includes(preference_associations_to_preload)
            if digest
              @refresh_presented_digest = digest
              @refresh_public_id = refresh_public_id
              pref =
                if refresh_public_id.present?
                  relation.find_by(public_id: refresh_public_id, token_digest: digest)
                else
                  relation.find_by(token_digest: digest)
                end

              if pref.present?
                refresh_device_id = extract_preference_refresh_device_id
                if refresh_device_id.blank? || pref.device_id.to_s != refresh_device_id.to_s
                  @preference_refresh_device_reason = refresh_device_id.blank? ? "missing" : "mismatch"
                  handle_preference_refresh_device_denied(pref, refresh_public_id)
                  return [nil, false]
                end
              end
              pref
            end
          end
        end

      if valid_refresh_preference?(preference)
        @preferences = preference
        return [preference, false]
      end

      if preference.present?
        if preference.replay?
          handle_preference_refresh_replay!(preference)
        else
          handle_preference_refresh_failed(preference, refresh_public_id)
        end
        return [nil, false]
      end

      return [nil, false] unless create_if_missing

      @refresh_presented_digest = nil
      @refresh_public_id = nil
      preference = create_new_preference_record!
      [preference, true]
    end

    def create_new_preference_record!
      expires_at = refresh_token_expiry
      generated_token = nil

      PreferenceRecord.connected_to(role: :writing) do
        PreferenceRecord.transaction do
          ensure_preference_status_defaults!
          @preferences = preference_class.create!(
            expires_at: expires_at,
            jti: Jit::Security::Jwt::JtiGenerator.generate,
            device_id: SecureRandom.uuid,
          )

          generated_token, verifier = generate_refresh_token(public_id: @preferences.public_id)
          @preferences.update!(
            token_digest: digest_refresh_token(verifier),
          )

          create_preference_options(
            @preferences,
            params.slice(
              Preference::IoKeys::Params::RI,
              Preference::IoKeys::Params::LX,
              Preference::IoKeys::Params::TZ,
              Preference::IoKeys::Params::CT,
            ),
          )

          create_audit_log(
            event_id: "CREATE_NEW_PREFERENCE_TOKEN",
            context: { token_created: true },
            expires_at: expires_at,
          )
          create_audit_log(
            event_id: "REFRESH_TOKEN_ROTATED",
            context: { refresh_token_rotated: true, expires_at: expires_at },
            expires_at: expires_at,
          )
        rescue ActiveRecord::RecordInvalid => e
          @preferences&.destroy
          raise e
        end
      end

      @refresh_token_value = generated_token
      set_refresh_token_cookie(generated_token, expires_at)
      set_preference_device_id_cookie!(@preferences.device_id, expires_at: expires_at)

      @preferences
    end

    def refresh_refresh_token_lifetime(preference)
      return if @refresh_token_value.blank? || preference.blank? || @refresh_presented_digest.blank?

      rotated_preference =
        PreferenceRecord.connected_to(role: :writing) do
          preference.class.rotate!(
            presented_digest: @refresh_presented_digest,
            device_id: preference.device_id,
            now: Time.current,
          )
        end

      unless rotated_preference
        replayed_preference = find_preference_by_presented_token
        if replayed_preference&.replay?
          handle_preference_refresh_replay!(replayed_preference)
          return
        end

        clear_preference_auth_cookies!
        @preference_refresh_failed = true
        return
      end

      new_token = rotated_preference.issued_refresh_token
      new_expiry = rotated_preference.expires_at

      @preferences = rotated_preference
      create_audit_log(
        event_id: "REFRESH_TOKEN_ROTATED",
        context: { refresh_token_rotated: true, expires_at: new_expiry },
        expires_at: new_expiry,
      )

      set_refresh_token_cookie(new_token, new_expiry)
      set_preference_device_id_cookie!(rotated_preference.device_id, expires_at: new_expiry)
      @refresh_token_value = new_token
    end

    def issue_access_token_from(preference)
      rotate_preference_jti!(preference)
      payload = build_preferences_payload(preference)
      token = Token.encode(
        payload,
        host: request.host,
        preference_type: preference.class.name,
        public_id: preference.public_id,
        jti: preference.jti,
      )
      return if token.blank?

      cookies[access_token_cookie_name] = preference_auth_cookie_options(expires_at: ACCESS_TOKEN_TTL.from_now).merge(
        value: token,
      )

      @preference_payload = Token.decode(token, host: request.host)
    end

    def build_preferences_payload(preference)
      association_prefix = preference.class.name.underscore
      option_prefix = preference.class.name.sub("Preference", "")
      language = preference.public_send("#{association_prefix}_language")&.option_id
      region = preference.public_send("#{association_prefix}_region")&.option_id
      timezone = preference.public_send("#{association_prefix}_timezone")&.option_id
      colortheme = preference.public_send("#{association_prefix}_colortheme")&.option_id

      {
        "lx" => option_id_to_language(language, option_prefix) || "ja",
        "ri" => option_id_to_region(region, option_prefix) || "jp",
        "tz" => option_id_to_timezone(timezone, option_prefix) || "Asia/Tokyo",
        "ct" => normalize_colortheme(option_id_to_colortheme(colortheme, option_prefix)) || "sy",
      }
    end

    def option_id_to_language(option_id, prefix)
      return if option_id.blank?

      option_class = Preference::ClassRegistry.option_class(prefix, :language)
      return "ja" if option_id == option_class::JA
      return "en" if option_class.const_defined?(:EN) && option_id == option_class::EN

      option_id.to_s.downcase
    end

    def option_id_to_region(option_id, prefix)
      return if option_id.blank?

      option_class = Preference::ClassRegistry.option_class(prefix, :region)
      return "jp" if option_id == option_class::JP
      return "us" if option_id == option_class::US

      option_id.to_s.downcase
    end

    def option_id_to_timezone(option_id, prefix)
      return if option_id.blank?

      option_class = Preference::ClassRegistry.option_class(prefix, :timezone)
      return "Asia/Tokyo" if option_id == option_class::ASIA_TOKYO
      return "Etc/UTC" if option_id == option_class::ETC_UTC

      option_id.to_s
    end

    def option_id_to_colortheme(option_id, prefix)
      return if option_id.blank?

      option_class = Preference::ClassRegistry.option_class(prefix, :colortheme)
      return "light" if option_id == option_class::LIGHT
      return "dark" if option_id == option_class::DARK
      return "system" if option_id == option_class::SYSTEM

      option_id.to_s
    end

    def preference_payload_preferences
      Token.extract_preferences(@preference_payload)
    end

    def preference_payload_value(key)
      preference_payload_preferences[key.to_s]
    end

    def preference_payload_public_id
      Token.extract_public_id(@preference_payload)
    end

    def preference_payload_jti
      Token.extract_jti(@preference_payload)
    end

    def clear_preference_refresh_failure!
      @preference_refresh_failed = false
    end

    def preference_refresh_failed?
      @preference_refresh_failed
    end

    def extract_preference_refresh_device_id
      header_device_id = request.headers[Preference::IoKeys::Headers::DEVICE_ID].to_s.presence
      cookie_device_id = read_preference_device_id_cookie

      if header_device_id.blank? && cookie_device_id.blank?
        @preference_refresh_device_reason = "missing"
        return nil
      end

      if header_device_id.present? && cookie_device_id.present? && header_device_id != cookie_device_id
        @preference_refresh_device_reason = "mismatch"
        return nil
      end

      header_device_id || cookie_device_id
    end

    def handle_preference_refresh_device_denied(preference, refresh_public_id)
      clear_preference_auth_cookies!
      @preference_refresh_failed = true

      Rails.logger.warn(
        {
          message: "Preference refresh denied",
          reason: @preference_refresh_device_reason || "missing",
          preference_type: preference_class.name,
          preference_public_id: preference&.public_id || refresh_public_id,
          request_id: request.request_id,
        },
      )
    end

    def handle_preference_refresh_failed(preference, refresh_public_id)
      clear_preference_auth_cookies!
      @preference_refresh_failed = true

      Rails.logger.warn(
        {
          message: "Preference refresh failed",
          preference_type: preference_class.name,
          preference_public_id: preference&.public_id || refresh_public_id,
          request_id: request.request_id,
        },
      )
    end

    def render_preference_refresh_error!
      if request.format.json?
        render json: {
          error: I18n.t("sign.token_refresh.errors.invalid_refresh_token"),
          error_code: "invalid_refresh_token",
        }, status: :unauthorized
      else
        head :unauthorized
      end
    end

    def valid_refresh_preference?(preference)
      preference.present? &&
        preference.status_id != preference_status_class::DELETED &&
        (preference.expires_at.nil? || preference.expires_at > Time.current) &&
        !preference.replay? &&
        !preference.revoked?
    end

    def find_preference_by_presented_token
      return nil if @refresh_presented_digest.blank?

      relation = preference_class.where(token_digest: @refresh_presented_digest)
      relation = relation.where(public_id: @refresh_public_id) if @refresh_public_id.present?
      relation.order(:id).last
    end

    def handle_preference_refresh_replay!(preference)
      now = Time.current

      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(compromised_at: now, revoked_at: now) if preference.compromised_at.nil?
      end

      clear_preference_auth_cookies!
      @preference_refresh_failed = true

      Rails.event.notify(
        "preference.token.refresh.replay_detected",
        preference_type: preference_class.name,
        preference_public_id: preference.public_id,
        replaced_by_id: preference.replaced_by_id,
        request_id: request.request_id,
      )
    end

    def rotate_preference_jti!(preference)
      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(jti: Jit::Security::Jwt::JtiGenerator.generate)
      end
    end

    # ==========================================================================
    # 6) Cookie/header/session helpers (I/O boundary)
    # ==========================================================================
    def preference_cookie_options(expires_at:, httponly:)
      ::Core::CookieOptions.for(
        surface: ::Core::Surface.current(request),
        request: request,
        expires: expires_at,
        httponly: httponly,
        secure: Rails.env.production?,
        same_site: :lax,
      )
    end

    def preference_auth_cookie_options(expires_at:)
      preference_cookie_options(expires_at: expires_at, httponly: true)
    end

    def access_token_cookie_name
      Preference::CookieName.access
    end

    def refresh_token_cookie_name
      Preference::CookieName.refresh
    end

    def preference_device_id_cookie_name
      Preference::CookieName.device(refresh_cookie_key: refresh_token_cookie_name)
    end

    def set_refresh_token_cookie(token, expires_at)
      cookies[refresh_token_cookie_name] = preference_cookie_options(expires_at: expires_at, httponly: true).merge(
        value: token,
      )
    end

    def set_preference_device_id_cookie!(device_id, expires_at:)
      cookies.encrypted[preference_device_id_cookie_name] = preference_cookie_options(
        expires_at: expires_at,
        httponly: true,
      ).merge(
        value: device_id,
      )
    end

    def read_preference_device_id_cookie
      cookies.encrypted[preference_device_id_cookie_name]
    end

    def clear_preference_auth_cookies!
      [access_token_cookie_name, refresh_token_cookie_name, preference_device_id_cookie_name].uniq.each do |cookie_name|
        cookies.delete(cookie_name, **preference_cookie_deletion_options)
      end
    end

    def preference_cookie_deletion_options
      opts = preference_cookie_options(expires_at: nil, httponly: true)
      opts.delete(:expires)
      opts
    end

    def preference_associations_to_preload
      prefix = preference_class.name.underscore
      [
        "#{prefix}_language",
        "#{prefix}_region",
        "#{prefix}_timezone",
        "#{prefix}_colortheme",
      ].map(&:to_sym)
    end

    def refresh_token_value
      params[Preference::IoKeys::Params::REFRESH_TOKEN].presence || cookies[refresh_token_cookie_name]
    end

    def refresh_token_expiry
      REFRESH_TOKEN_TTL.from_now
    end

    def refresh_token_lookup_digest(token)
      legacy_refresh_token_digest(token)
    end

    # ==========================================================================
    # 7) Child-record lazy helpers
    # ==========================================================================
    def load_or_create_preference_child(child_type, default_attributes = {})
      association_name = "#{preference_prefix_underscore}_#{child_type.downcase}"
      child = @preferences.public_send(association_name)
      return child if child.present?

      # Ensure the parent preference record is fresh
      @preferences.reload if @preferences.persisted?

      # Try finding again in case it was created concurrently
      child = @preferences.public_send(association_name)
      return child if child.present?

      begin
        @preferences.public_send("create_#{association_name}!", default_attributes)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        @preferences.reload
        @preferences.public_send(association_name)
      end
    end
  end
end
