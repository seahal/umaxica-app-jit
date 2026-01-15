# frozen_string_literal: true

require "jwt"
require "sha3"

module Preference
  module JwtConfiguration
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
      raise "Preference JWT private key not configured in credentials" if private_key_base64.blank?

      private_key_der = Base64.decode64(private_key_base64)
      OpenSSL::PKey::EC.new(private_key_der)
    end

    def self.public_key
      public_key_base64 = ENV["PREFERENCE_JWT_PUBLIC_KEY"] ||
        Rails.application.credentials.dig(:JWT, :PREFERENCE, :PUBLIC_KEY)
      raise "Preference JWT public key not configured in credentials" if public_key_base64.blank?

      public_key_der = Base64.decode64(public_key_base64)
      OpenSSL::PKey::EC.new(public_key_der)
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
          "iat" => now.to_i,
          "exp" => (now + ACCESS_TOKEN_TTL).to_i,
        }
      end

      def decode_options
        {
          algorithms: [JWT_ALGORITHM],
          verify_iss: true,
          iss: JwtConfiguration.issuer,
        }
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
        end
      end
    end
  end

  module Base
    extend ActiveSupport::Concern

    ACCESS_TOKEN_TTL = Token::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = 400.days

    private

    def set_preferences_cookie
      return if load_access_token_payload

      preference, created = load_preference_record_from_refresh_token!(create_if_missing: true)
      return if preference.blank?

      refresh_refresh_token_lifetime(preference) unless created
      issue_access_token_from(preference)
      nil
    end

    def set_color_theme
      ""
    end

    def create_preference_options(preference)
      prefix = preference.class.name.gsub("Preference", "")

      "#{prefix}PreferenceCookie".constantize.create!(
        preference_id: preference.id,
        targetable: false,
        performant: false,
        functional: false,
      )

      "#{prefix}PreferenceTimezone".constantize.create!(
        preference_id: preference.id,
        option_id: "Asia/Tokyo",
      )

      "#{prefix}PreferenceLanguage".constantize.create!(
        preference_id: preference.id,
        option_id: "JA",
      )

      "#{prefix}PreferenceRegion".constantize.create!(
        preference_id: preference.id,
        option_id: "JP",
      )

      "#{prefix}PreferenceColortheme".constantize.create!(
        preference_id: preference.id,
        option_id: "system",
      )
    end

    def set_locale_from_params
      locale_param = params[:lx].presence
      locale_from_region = locale_from_region_param(params[:ri])
      locale = locale_param || locale_from_region || session[:language]&.downcase || I18n.default_locale
      I18n.locale = locale.to_s.downcase
    end

    def locale_from_region_param(region_param)
      region = region_param.to_s.downcase
      return if region.blank?

      {
        "jp" => "ja",
        "us" => "en",
      }[region]
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

    def create_audit_log(event_id:, context:, expires_at: nil)
      expires_at_value = expires_at || Preference::Core::COOKIE_EXPIRY.from_now

      AuditRecord.connected_to(role: :writing) do
        preference_audit_class.create!(
          subject_id: @preferences.id.to_s,
          subject_type: @preferences.class.name,
          event_id: event_id,
          level_id: "INFO",
          occurred_at: Time.current,
          expires_at: expires_at_value,
          ip_address: request.remote_ip || "0.0.0.0",
          context: context,
        )
      end
    end

    def preference_prefix
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

      child_record = child_class.find_by(preference_id: @preferences.id)

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
            refresh_refresh_token_lifetime(@preferences)
            issue_access_token_from(@preferences)
          end
        end
      end
    end

    def sanitize_option_id(params)
      params[:option_id] = nil if params[:option_id].blank?
      params
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
          digest = refresh_token_digest(token_value)
          preference_class.includes(preference_associations_to_preload).find_by(token_digest: digest)
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
      token = SecureRandom.urlsafe_base64(48)
      token_digest = refresh_token_digest(token)
      expires_at = refresh_token_expiry

      PreferenceRecord.connected_to(role: :writing) do
        ActiveRecord::Base.transaction do
          @preferences = preference_class.create!(
            token_digest: token_digest,
            expires_at: expires_at,
            jti: SecureRandom.uuid_v7,
          )

          create_preference_options(@preferences)

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

      @refresh_token_value = token
      set_refresh_token_cookie(token, expires_at)

      @preferences
    end

    def refresh_refresh_token_lifetime(preference)
      return if @refresh_token_value.blank? || preference.blank?

      new_token = SecureRandom.urlsafe_base64(48)
      new_digest = refresh_token_digest(new_token)
      new_expiry = refresh_token_expiry

      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(
          token_digest: new_digest,
          expires_at: new_expiry,
        )
      end

      set_refresh_token_cookie(new_token, new_expiry)
      @refresh_token_value = new_token
    end

    def issue_access_token_from(preference)
      ensure_preference_jti!(preference)
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
      prefix = preference.class.name.underscore
      language = preference.public_send("#{prefix}_language")&.option_id
      region = preference.public_send("#{prefix}_region")&.option_id
      timezone = preference.public_send("#{prefix}_timezone")&.option_id
      colortheme = preference.public_send("#{prefix}_colortheme")&.option_id

      {
        "lx" => language.presence || "JA",
        "ri" => region.presence || "JP",
        "tz" => timezone.presence || "Asia/Tokyo",
        "ct" => colortheme.presence || "system",
      }
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

    def refresh_token_digest(token)
      SHA3::Digest::SHA3_384.digest(token)
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
        preference.status_id != "DELETED" &&
        (preference.expires_at.nil? || preference.expires_at > Time.current)
    end

    def ensure_preference_jti!(preference)
      return if preference.jti.present?

      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(jti: SecureRandom.uuid_v7)
      end
    end

    def rotate_preference_jti!(preference)
      PreferenceRecord.connected_to(role: :writing) do
        preference.update!(jti: SecureRandom.uuid_v7)
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
      return :all unless Rails.env.development?

      nil
    end
  end
end
