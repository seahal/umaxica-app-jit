require "uri"
require "json"

module Apex
  module App
    class RootsController < ApplicationController
      PREFERENCE_KEYS = %w[lx ri tz ct].freeze
      PREFERENCE_COOKIE_KEY = :apex_app_preferences
      DEFAULT_PREFERENCES = {
        "lx" => "ja",
        "ri" => "jp",
        "tz" => "jst",
        "ct" => "sy"
      }.freeze
      ALLOWED_PREFERENCE_VALUES = {
        "lx" => %w[ja en],
        "ri" => %w[jp us],
        "tz" => %w[jst utc],
        "ct" => %w[li dr sy]
      }.freeze
      COERCED_PREFERENCE_VALUES = {
        "lx" => { "kr" => "ja" },
        "ri" => { "sk" => "jp" },
        "tz" => { "kst" => "jst" },
        "ct" => {
          "auto" => "sy",
          "system" => "sy",
          "darkmode" => "dr",
          "dark" => "dr",
          "light" => "li",
          "dk" => "dr",
          "lt" => "li"
        }
      }.freeze

      before_action :ensure_preference_context

      def index
      end

      private

      def ensure_preference_context
        resolved = resolve_preferences

        if redirect_required?(resolved)
          write_preference_cookie(resolved)
          redirect_to resolved_redirect_url(resolved)
          nil
        else
          write_preference_cookie(resolved) if preferences_changed?(resolved)
          apply_locale(resolved["lx"])
          @preferences = resolved
        end
      end

      def resolve_preferences
        @cookie_preferences = read_cookie_preferences
        param_preferences = extract_param_preferences

        resolved = DEFAULT_PREFERENCES.dup
        resolved.merge!(@cookie_preferences) if @cookie_preferences.present?
        resolved.merge!(param_preferences) if param_preferences.present?
        resolved
      end

      def read_cookie_preferences
        raw = cookies.signed[PREFERENCE_COOKIE_KEY]
        return if raw.blank?

        parsed = JSON.parse(raw)

        return unless parsed.is_a?(Hash)

        sanitized = {}
        parsed.slice(*PREFERENCE_KEYS).each do |key, value|
          sanitized_value = sanitize_preference(key, value)
          sanitized[key] = sanitized_value if sanitized_value
        end

        sanitized
      end

      def extract_param_preferences
        sanitized = {}

        PREFERENCE_KEYS.each do |key|
          next unless request.query_parameters.key?(key)

          sanitized_value = sanitize_preference(key, request.query_parameters[key])
          sanitized[key] = sanitized_value if sanitized_value
        end

        sanitized
      end

      def sanitize_preference(key, value)
        allowed = ALLOWED_PREFERENCE_VALUES[key]
        candidate = value.to_s.downcase

        return candidate if allowed&.include?(candidate)

        coerced = COERCED_PREFERENCE_VALUES.dig(key, candidate)
        coerced ||= DEFAULT_PREFERENCES[key]

        return unless coerced
        coerced if allowed&.include?(coerced)
      end

      def redirect_required?(resolved)
        PREFERENCE_KEYS.any? do |key|
          expected = resolved[key]
          default = DEFAULT_PREFERENCES[key]
          actual_present = request.query_parameters.key?(key)
          actual = request.query_parameters[key]&.to_s&.downcase

          if key == "ri"
            !actual_present || actual != expected
          elsif expected == default
            actual_present
          else
            actual != expected
          end
        end
      end

      def resolved_redirect_url(resolved)
        query = request.query_parameters.except(*PREFERENCE_KEYS)

        resolved.each do |key, value|
          next if key != "ri" && value == DEFAULT_PREFERENCES[key]

          query[key] = value
        end

        uri = URI.parse(request.url)
        uri.query = query.to_query.presence
        uri.to_s
      end

      def preferences_changed?(resolved)
        current_cookie = @cookie_preferences
        current_cookie.blank? || PREFERENCE_KEYS.any? { |key| current_cookie[key] != resolved[key] }
      end

      def write_preference_cookie(resolved)
        cookies.permanent.signed[PREFERENCE_COOKIE_KEY] = {
          value: resolved.slice(*PREFERENCE_KEYS).to_json,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax
        }
      end

      def apply_locale(language_code)
        case language_code
        when "en"
          I18n.locale = :en
        else
          I18n.locale = :ja
        end
      end
    end
  end
end
