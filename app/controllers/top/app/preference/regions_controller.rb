# frozen_string_literal: true

require "json"

module Top
  module App
    module Preference
      class RegionsController < ApplicationController
        include PreferenceConstants

        SELECTABLE_LANGUAGES = %w[JA EN].freeze
        DEFAULT_LANGUAGE = "JA"
        SELECTABLE_REGIONS = %w[US JP].freeze
        DEFAULT_REGION = "US"
        SELECTABLE_TIMEZONES = %w[Etc/UTC Asia/Tokyo].freeze
        DEFAULT_TIMEZONE = "Asia/Tokyo"

        Result = Struct.new(:updated, :error_key) do
          def updated?
            !!updated
          end

          def error?
            error_key.present?
          end
        end

        def edit
          set_edit_variables
        end

        def update
          result = apply_updates(preference_params)

          if result.error?
            flash[:alert] = I18n.t(result.error_key)
            set_edit_variables
            render :edit, status: :unprocessable_content
          else
            persist_preference_cookie!
            flash[:notice] = t("messages.region_settings_updated_successfully") if result.updated?
            redirect_to edit_top_app_preference_region_url
          end
        end

        private

        def set_edit_variables
          # Read from 2-letter URL parameters (lx, ri, tz, ct) for better URL readability
          region_param = normalize_region_from_param(params[:ri].presence)
          language_param = normalize_language_from_param(params[:lx].presence)
          timezone_param = normalize_timezone_from_param(params[:tz].presence)
          theme_param = normalize_theme_from_param(params[:ct].presence)

          @current_region = region_param || session[:region] || DEFAULT_REGION
          @current_country = session[:country] || DEFAULT_REGION
          @current_language = language_param || session[:language] || DEFAULT_LANGUAGE
          @current_theme = theme_param || session[:theme]

          timezone_candidate = timezone_param || session[:timezone]
          timezone = resolve_timezone(timezone_candidate) || resolve_timezone(DEFAULT_TIMEZONE)
          @current_timezone = timezone ? timezone.to_s : DEFAULT_TIMEZONE
        end

        def preference_params
          params.permit(:region, :country, :language, :timezone)
        end

        def apply_updates(preferences)
          updated = false

          if preferences[:region].present?
            session[:region] = preferences[:region]
            updated = true
          end

          if preferences[:country].present?
            session[:country] = preferences[:country]
            updated = true
          end

          if preferences[:language].present?
            language_result = update_language(preferences[:language])
            return language_result if language_result.error?
            updated ||= language_result.updated?
          end

          if preferences[:timezone].present?
            timezone_result = update_timezone(preferences[:timezone])
            return timezone_result if timezone_result.error?
            updated ||= timezone_result.updated?
          end

          Result.new(updated, nil)
        end

        def update_language(language)
          normalized = language.to_s.upcase

          unless SELECTABLE_LANGUAGES.include?(normalized)
            return Result.new(false, "sign.app.preferences.languages.unsupported")
          end

          session[:language] = normalized
          Result.new(true, nil)
        end

        def update_timezone(timezone)
          candidate = timezone.to_s
          return Result.new(false, "sign.app.preferences.timezones.invalid") unless SELECTABLE_TIMEZONES.any? { |identifier| identifier.casecmp?(candidate) }

          zone = resolve_timezone(candidate)
          return Result.new(false, "sign.app.preferences.timezones.invalid") unless zone

          session[:timezone] = zone_identifier(zone, candidate)
          Result.new(true, nil)
        end

        def resolve_timezone(value)
          return if value.blank?

          return value if value.is_a?(ActiveSupport::TimeZone)

          candidate = value.to_s

          ActiveSupport::TimeZone[candidate] || ActiveSupport::TimeZone.all.find do |zone|
            timezone_matches?(zone, candidate)
          end
        end

        def timezone_matches?(zone, candidate)
          [ zone.tzinfo&.identifier, zone.name, zone.to_s ].compact.any? do |option|
            option.casecmp?(candidate)
          end
        end

        def zone_identifier(zone, fallback)
          zone.tzinfo&.identifier || zone.name || fallback.to_s
        end

        def persist_preference_cookie!
          cookies.permanent.signed[PREFERENCE_COOKIE_KEY] = {
            value: cookie_preferences.to_json,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :lax
          }
        end

        def cookie_preferences
          {
            "lx" => normalize_language_for_cookie,
            "ri" => normalize_region_for_cookie,
            "tz" => normalize_timezone_for_cookie,
            "ct" => normalize_theme_for_cookie
          }.compact.presence || DEFAULT_PREFERENCES
        end

        def normalize_language_for_cookie
          case session[:language].to_s.downcase
          when "en"
            "en"
          else
            "ja"
          end
        end

        def normalize_region_for_cookie
          case session[:region].to_s.downcase
          when "jp"
            "jp"
          when "us"
            "us"
          else
            DEFAULT_PREFERENCES["ri"]
          end
        end

        def normalize_timezone_for_cookie
          candidate = session[:timezone].presence || DEFAULT_TIMEZONE
          candidate_string = candidate.is_a?(ActiveSupport::TimeZone) ? candidate.tzinfo&.identifier : candidate.to_s

          case candidate_string
          when /\Aasia\/tokyo\z/i
            "jst"
          when /\Aetc\/utc\z/i, /\Autc\z/i
            "utc"
          else
            DEFAULT_PREFERENCES["tz"]
          end
        end

        def normalize_theme_for_cookie
          candidate = session[:theme].presence || existing_cookie_preferences["ct"]

          case candidate.to_s.downcase
          when "dark", "dr", "dk"
            "dr"
          when "system", "sy"
            "sy"
          when "light", "li", "lt"
            "li"
          else
            DEFAULT_PREFERENCES["ct"]
          end
        end

        def existing_cookie_preferences
          return @existing_cookie_preferences if defined?(@existing_cookie_preferences)

          raw = cookies.signed[PREFERENCE_COOKIE_KEY]
          @existing_cookie_preferences =
            begin
              parsed = JSON.parse(raw)
              parsed.is_a?(Hash) ? parsed : {}
            rescue JSON::ParserError, TypeError
              {}
            end
        end

        def normalize_region_from_param(value)
          return if value.blank?

          case value.to_s.downcase
          when "jp"
            "JP"
          when "us"
            "US"
          else
            value.to_s.upcase
          end
        end

        def normalize_language_from_param(value)
          return if value.blank?

          case value.to_s.downcase
          when "ja"
            "JA"
          when "en"
            "EN"
          else
            value.to_s.upcase
          end
        end

        def normalize_timezone_from_param(value)
          return if value.blank?

          case value.to_s.downcase
          when "jst"
            "Asia/Tokyo"
          when "utc"
            "Etc/UTC"
          when "kst"
            "Asia/Seoul"
          else
            value.to_s
          end
        end

        def normalize_theme_from_param(value)
          return if value.blank?

          case value.to_s.downcase
          when "dr", "dk"
            "dark"
          when "sy"
            "system"
          when "li", "lt"
            "light"
          else
            value.to_s
          end
        end
      end
    end
  end
end
