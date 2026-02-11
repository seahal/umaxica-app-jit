# frozen_string_literal: true

require "jwt"
require "sha3"
require "concurrent"

module Preference
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
          next false if aud.blank?

          host == aud || host.end_with?(".#{aud}")
        end
      end

      def build_payload(preferences, host, preference_type, public_id, jti)
        {
          "preferences" => preferences.slice("lx", "ri", "tz", "ct"),
          "host" => host,
          "preference_type" => preference_type,
          "public_id" => public_id,
          "jti" => jti,
          **jwt_claims,
        }
      end

      def jwt_claims
        now = Time.current

        {
          "iss" => JwtConfiguration.issuer,
          "aud" => resolve_audiences,
          "nonce" => SecureRandom.uuid_v7,
          "iat" => now.to_i,
          "exp" => (now + ACCESS_TOKEN_TTL).to_i,
        }
      end

      def decode_options
        options = {
          algorithms: [JWT_ALGORITHM],
          verify_exp: true,
          verify_iss: true,
          iss: JwtConfiguration.issuer,
        }

        # Only verify audience if configured
        audiences = JwtConfiguration.audiences
        if audiences.present?
          options[:verify_aud] = true
          options[:aud] = audiences
        else
          options[:verify_aud] = false
        end

        options
      end

      def resolve_audiences
        audiences = JwtConfiguration.audiences
        audiences.presence || []
      end

      def normalize_audiences(aud_claim)
        case aud_claim
        when Array then aud_claim
        when String then [aud_claim]
        else []
             raise
        end
      end
    end
  end

  module Base
    extend ActiveSupport::Concern
    include RefreshTokenShared

    ACCESS_TOKEN_TTL = Token::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = 400.days
    THEME_COOKIE_KEY = "jit_ct"
    LEGACY_THEME_COOKIE_KEY = "ct"
    LANGUAGE_COOKIE_KEY = "jit_lx"
    TIMEZONE_COOKIE_KEY = "jit_tz"

    included do
      before_action :set_preferences_cookie
    end

    private

    def set_preferences_cookie
      return if load_access_token_payload

      preference, _ = load_preference_record_from_refresh_token!(create_if_missing: true)
      return if preference.blank?

      # Rotate refresh token on access token re-issue to limit replay if leaked.
      refresh_refresh_token_lifetime(preference)
      issue_access_token_from(preference)
      nil
    end

    def set_color_theme
      theme = normalize_colortheme(params[:ct].presence)
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
        timezone: "#{prefix}PreferenceTimezoneOption".constantize,
        language: "#{prefix}PreferenceLanguageOption".constantize,
        region: "#{prefix}PreferenceRegionOption".constantize,
        colortheme: "#{prefix}PreferenceColorthemeOption".constantize,
      }
    end

    def create_preference_cookie(prefix, preference)
      "#{prefix}PreferenceCookie".constantize.create!(
        preference_id: preference.id,
        targetable: false,
        performant: false,
        functional: false,
      )
    end

    def create_preference_option_records(prefix, preference, option_ids)
      create_preference_option_record(prefix, preference, "Timezone", option_ids[:timezone])
      create_preference_option_record(prefix, preference, "Language", option_ids[:language])
      create_preference_option_record(prefix, preference, "Region", option_ids[:region])
      create_preference_option_record(prefix, preference, "Colortheme", option_ids[:colortheme])
    end

    def ensure_preference_option_defaults(prefix)
      option_classes = preference_option_classes(prefix).values

      PreferenceRecord.connected_to(role: :writing) do
        option_classes.each do |option_class|
          if option_class.respond_to?(:ensure_defaults!)
            option_class.ensure_defaults!
            next
          end

          ids =
            option_class.constants(false).filter_map do |const_name|
              value = option_class.const_get(const_name)
              value if value.is_a?(Integer)
            end
          next if ids.empty?

          existing_ids = option_class.where(id: ids).pluck(:id)
          missing_ids = ids - existing_ids
          next if missing_ids.empty?

          # Intentionally skip validations for bulk insert of default option IDs
          # rubocop:disable Rails/SkipsModelValidations
          option_class.insert_all(
            missing_ids.map { |id| { id: id } },
            unique_by: :primary_key,
          )
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    rescue StandardError => e
      Rails.logger.error("ensure_preference_option_defaults failed: #{e.class} - #{e.message}")
    end

    def create_preference_option_record(prefix, preference, suffix, option_id)
      "#{prefix}Preference#{suffix}".constantize.create!(
        preference_id: preference.id,
        option_id: option_id,
      )
    end

    COLORTHEME_OPTION_MAP = {
      "sy" => "system",
      "system" => "system",
      "dr" => "dark",
      "dark" => "dark",
      "li" => "light",
      "light" => "light",
    }.freeze

    COLORTHEME_SHORT_MAP = {
      "sy" => "sy",
      "system" => "sy",
      "dr" => "dr",
      "dark" => "dr",
      "li" => "li",
      "light" => "li",
    }.freeze

    def normalize_colortheme(value)
      return nil if value.blank?

      COLORTHEME_SHORT_MAP[value.to_s.downcase]
    end

    def write_preference_cookie(key, value)
      cookie_options = {
        value: value,
        expires: REFRESH_TOKEN_TTL.from_now,
        secure: Rails.env.production?,
        same_site: :lax,
      }
      domain = cookie_domain
      cookie_options[:domain] = domain if domain.present?
      cookies[key] = cookie_options
    end

    def set_locale_from_params
      candidates = [
        params[:lx],
        locale_from_region_param(params[:ri]),
        preference_payload_value("lx"),
        preference_language_from_record,
        session[:language],
        I18n.default_locale,
      ]
      locale = candidates.filter_map { |value| normalized_locale(value) }.first
      I18n.locale = locale || I18n.default_locale
    end

    def locale_from_region_param(region_param)
      region = region_param.to_s.downcase
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
          path_parts = controller_path.split("/")
          prefix = path_parts[1]&.capitalize
          "#{prefix}Preference".constantize
        end
    end

    def preference_audit_class
      @preference_audit_class ||= "#{preference_class.name}Audit".constantize
    end

    def preference_audit_event_class
      @preference_audit_event_class ||= "#{preference_class.name}AuditEvent".constantize
    end

    def preference_audit_level_class
      @preference_audit_level_class ||= "#{preference_class.name}AuditLevel".constantize
    end

    def preference_status_class
      @preference_status_class ||= "#{preference_class.name}Status".constantize
    end

    def normalize_preference_audit_event_id(event_id)
      return if event_id.blank?
      return event_id if event_id.is_a?(Integer)

      if preference_audit_event_class.const_defined?(event_id)
        preference_audit_event_class.const_get(event_id)
      else
        event_id
      end
    end

    def create_audit_log(event_id:, context:, expires_at: nil)
      expires_at_value = expires_at || Preference::Core::COOKIE_EXPIRY.from_now
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

    def association_name_for_region
      @association_name_for_region ||= :"#{preference_class.name.underscore}_region"
    end

    def association_name_for_language
      @association_name_for_language ||= :"#{preference_class.name.underscore}_language"
    end

    def preference_associations_to_preload
      [association_name_for_region, association_name_for_language]
    end

    def load_or_create_preference_child(child_type, default_attributes = {})
      raise PreferenceOperationError if @preferences.blank?

      prefix = preference_prefix_underscore
      child_class = "#{@preferences.class.name}#{child_type}".constantize
      instance_var = "@preference_#{child_type.downcase}"

      child_record =
        PreferenceRecord.connected_to(role: :writing) do
          child_class.find_by(preference_id: @preferences.id)
        end

      if child_record.present?
        instance_variable_set(instance_var, child_record)
        return child_record
      end

      begin
        child_record = @preferences.public_send("create_#{prefix}_#{child_type.downcase}!", default_attributes)
        instance_variable_set(instance_var, child_record)
        child_record
      rescue ActiveRecord::RecordNotUnique
        child_record = child_class.find_by!(preference_id: @preferences.id)
        instance_variable_set(instance_var, child_record)
        child_record
      end
    end

    def update_preference_child_with_audit(child_record, params, event_id)
      PreferenceRecord.transaction do
        child_record.assign_attributes(params)

        if child_record.changed?
          child_record.save!

          create_audit_log(
            event_id: event_id,
            context: child_record.previous_changes,
          )

          if @preferences.present?
            # Reload to avoid stale association cache when issuing new token.
            @preferences.reload
            refresh_refresh_token_lifetime(@preferences)
            issue_access_token_from(@preferences)
          end
        end
      end
    end

    def resolve_option_id_from_param(param_value, option_type, default_option_id, prefix)
      return default_option_id if param_value.blank?

      # Convert param_value to uppercase constant name
      # For example: "jp" -> "JP", "asia/tokyo" -> "ASIA_TOKYO"
      const_name = param_value.to_s.upcase.tr("/", "_").tr("-", "_")

      # Special handling for colortheme: normalize first
      if option_type == :colortheme
        canonical = canonical_colortheme_option_id(param_value)
        const_name = canonical.to_s.upcase if canonical.present?
      end

      option_class_name =
        case option_type
        when :colortheme then "#{prefix}PreferenceColorthemeOption"
        when :language then "#{prefix}PreferenceLanguageOption"
        when :region then "#{prefix}PreferenceRegionOption"
        when :timezone then "#{prefix}PreferenceTimezoneOption"
        end

      return default_option_id if option_class_name.blank?

      begin
        option_class = option_class_name.constantize
        if option_class.const_defined?(const_name)
          option_class.const_get(const_name)
        else
          default_option_id
        end
      rescue NameError
        default_option_id
      end
    end

    def sanitize_option_id(params, option_type: nil)
      params[:option_id] = nil if params[:option_id].blank?

      return params if params[:option_id].blank?

      # If option_id is already an integer, use it as-is
      if params[:option_id].is_a?(Integer) || params[:option_id].to_s.match?(/^\d+$/)
        params[:option_id] = params[:option_id].to_i
        return params
      end

      prefix = preference_class.name.gsub("Preference", "")
      option_class_name =
        case option_type
        when :colortheme then "#{prefix}PreferenceColorthemeOption"
        when :language then "#{prefix}PreferenceLanguageOption"
        when :region then "#{prefix}PreferenceRegionOption"
        when :timezone then "#{prefix}PreferenceTimezoneOption"
        end

      if option_class_name
        name = (option_type == :colortheme) ? canonical_colortheme_option_id(params[:option_id]) : params[:option_id]
        if name.present?
          option_class = option_class_name.constantize
          # Try to find constant matching the name (upcase)
          # For Language/Region/Timezone, the input might be "US", "EN", "Asia/Tokyo"
          # We need to map these to constants like US, EN, ASIA_TOKYO
          const_name = name.to_s.upcase.tr("/", "_").tr("-", "_")
          Rails.logger.debug do
            "DEBUG: sanitize #{preference_class.name} #{option_type} " \
              "name='#{name}' const='#{const_name}' " \
              "found=#{option_class.const_defined?(const_name)}"
          end

          if option_class.const_defined?(const_name)
            params[:option_id] = option_class.const_get(const_name)
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

    def load_access_token_payload
      token = cookies[access_token_cookie_name]
      return false if token.blank?

      payload = Token.decode(token, host: request.host)
      return false if payload.blank?
      return false if Token.extract_preference_type(payload) != preference_class.name

      @preference_payload = payload
      true
    end

    def load_preference_record_from_refresh_token!(create_if_missing: false)
      return [@preferences, false] if @preferences.present?

      token_value = refresh_token_value
      @refresh_token_value = token_value
      preference =
        if token_value.present?
          digest = refresh_token_lookup_digest(token_value)
          PreferenceRecord.connected_to(role: :writing) do
            preference_class.includes(preference_associations_to_preload).find_by(token_digest: digest) if digest
          end
        end

      if valid_refresh_preference?(preference)
        @preferences = preference
        return [preference, false]
      end

      return [nil, false] unless create_if_missing

      preference = create_new_preference_record!
      [preference, true]
    end

    def create_new_preference_record!
      expires_at = refresh_token_expiry
      generated_token = nil

      PreferenceRecord.connected_to(role: :writing) do
        ActiveRecord::Base.transaction do
          ensure_preference_status_defaults!
          @preferences = preference_class.create!(
            expires_at: expires_at,
            jti: Jit::Security::Jwt::JtiGenerator.generate,
          )

          generated_token, verifier = generate_refresh_token(public_id: @preferences.public_id)
          @preferences.update!(
            token_digest: digest_refresh_token(verifier),
          )

          create_preference_options(@preferences, params.slice(:ri, :lx, :tz, :ct))

          create_audit_log(
            event_id: "CREATE_NEW_PREFERENCE_TOKEN",
            context: { token_created: true },
            expires_at: expires_at,
          )
        rescue ActiveRecord::RecordInvalid => e
          @preferences&.destroy
          raise e
        end
      end

      @refresh_token_value = generated_token
      set_refresh_token_cookie(generated_token, expires_at)

      @preferences
    end

    def ensure_preference_status_defaults!
      status_class = "#{preference_class.name}Status".safe_constantize
      return unless status_class&.respond_to?(:ensure_defaults!)

      status_class.ensure_defaults!
    end

    def refresh_refresh_token_lifetime(preference)
      return if @refresh_token_value.blank? || preference.blank?

      new_token, verifier = generate_refresh_token(public_id: preference.public_id)
      new_digest = digest_refresh_token(verifier)
      new_expiry = refresh_token_expiry

      # TODO: Detect refresh token reuse (theft) by tracking previous token digest.
      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(
          token_digest: new_digest,
          expires_at: new_expiry,
        )
      end

      @preferences ||= preference
      create_audit_log(
        event_id: "REFRESH_TOKEN_ROTATED",
        context: { refresh_token_rotated: true, expires_at: new_expiry },
        expires_at: new_expiry,
      )

      set_refresh_token_cookie(new_token, new_expiry)
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

      cookie_options = {
        value: token,
        expires: ACCESS_TOKEN_TTL.from_now,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
      }
      domain = cookie_domain
      cookie_options[:domain] = domain if domain.present?
      cookies[access_token_cookie_name] = cookie_options

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

      option_class = "#{prefix}PreferenceLanguageOption".constantize
      return "ja" if option_id == option_class::JA
      return "en" if option_class.const_defined?(:EN) && option_id == option_class::EN

      option_id.to_s.downcase
    end

    def option_id_to_region(option_id, prefix)
      return if option_id.blank?

      option_class = "#{prefix}PreferenceRegionOption".constantize
      return "jp" if option_id == option_class::JP
      return "us" if option_id == option_class::US

      option_id.to_s.downcase
    end

    def option_id_to_timezone(option_id, prefix)
      return if option_id.blank?

      option_class = "#{prefix}PreferenceTimezoneOption".constantize
      return "Asia/Tokyo" if option_id == option_class::ASIA_TOKYO
      return "Etc/UTC" if option_id == option_class::ETC_UTC

      option_id.to_s
    end

    def option_id_to_colortheme(option_id, prefix)
      return if option_id.blank?

      option_class = "#{prefix}PreferenceColorthemeOption".constantize
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

    def ensure_preferences_record
      load_preference_record_from_refresh_token!(create_if_missing: true)
    end

    def refresh_token_expiry
      REFRESH_TOKEN_TTL.from_now
    end

    def refresh_token_cookie_name
      Rails.env.production? ? "__Secure-jit_preference_refresh" : "jit_preference_refresh"
    end

    def refresh_token_value
      cookies[refresh_token_cookie_name]
    end

    def refresh_token_lookup_digest(token)
      parsed = parse_refresh_token(token)
      return digest_refresh_token(parsed.last) if parsed

      # Legacy tokens were stored as a flat base64 string without the public_id prefix.
      # TODO (Apr 1, 2026): once every client has rotated, remove this branch and
      # purge digests that still match legacy SHA3 values.
      return legacy_refresh_token_digest(token) unless token.include?(refresh_token_separator)

      nil
    end

    def set_refresh_token_cookie(token, expires_at)
      options = {
        value: token,
        expires: expires_at,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
      }
      domain = cookie_domain
      options[:domain] = domain if domain.present?
      cookies[refresh_token_cookie_name] = options
    end

    def access_token_cookie_name
      if Rails.env.production?
        "__Secure-jit_preference_access"
      else
        "jit_preference_access"
      end
    end

    def valid_refresh_preference?(preference)
      preference.present? &&
        preference.status_id != preference_status_class::DELETED &&
        (preference.expires_at.nil? || preference.expires_at > Time.current)
    end

    def ensure_preference_jti!(preference)
      return if preference.jti.present?

      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(jti: Jit::Security::Jwt::JtiGenerator.generate)
      end
    end

    def rotate_preference_jti!(preference)
      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(jti: Jit::Security::Jwt::JtiGenerator.generate)
      end
    end

    def verify_jti_for_write!
      return if @preference_payload.blank?

      jti_in_token = preference_payload_jti
      public_id = preference_payload_public_id
      return if jti_in_token.blank? || public_id.blank?

      PreferenceRecord.connected_to(role: :writing) do
        preference = preference_class.find_by(public_id: public_id)

        if preference.blank? || preference.jti != jti_in_token
          head :unauthorized
        end
      end
    end

    def cookie_domain
      configured = ENV["PREFERENCE_COOKIE_DOMAIN"]&.strip
      return formatted_domain(configured) if configured.present?
      return nil unless Rails.env.production?

      formatted_domain(derive_cookie_domain_from_host)
    end

    def derive_cookie_domain_from_host
      return nil unless request&.host

      host_parts = request.host.split(".")
      return nil if host_parts.length < 2

      host_parts.last(2).join(".")
    end

    def formatted_domain(value)
      return nil if value.blank?

      value.start_with?(".") ? value : ".#{value}"
    end

    def preference_language_from_record
      return if @preferences.blank?

      association = "#{@preferences.class.name.underscore}_language"
      option_id = @preferences.public_send(association)&.option_id
      option_id_to_language(option_id, preference_prefix)
    rescue NoMethodError
      nil
    end
  end
end
