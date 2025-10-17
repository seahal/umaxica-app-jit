module Apex
  module App
    module Preference
      class RegionsController < ApplicationController
        SELECTABLE_LANGUAGES = %w[JA EN].freeze
        DEFAULT_LANGUAGE = "JA"
        SELECTABLE_REGIONS = %w[US JP].freeze
        DEFAULT_REGION = "US"
        SELECTABLE_TIMEZONES = %w[Etc/UTC Asia/Tokyo].freeze
        DEFAULT_TIMEZONE = "Asia/Tokyo"
        PREFERENCE_COOKIE_KEY = :apex_app_preferences
        DEFAULT_QUERY_PREFERENCES = {
          "lx" => "ja",
          "ri" => "jp",
          "tz" => "jst"
        }.freeze

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
            redirect_to edit_apex_app_preference_region_url
          end
        end

        private

        def set_edit_variables
          @current_region = session[:region] || DEFAULT_REGION
          @current_country = session[:country] || DEFAULT_REGION
          @current_language = session[:language] || DEFAULT_LANGUAGE

          timezone = resolve_timezone(session[:timezone]) || resolve_timezone(DEFAULT_TIMEZONE)
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
            return Result.new(false, "apex.app.preferences.languages.unsupported")
          end

          session[:language] = normalized
          Result.new(true, nil)
        end

        def update_timezone(timezone)
          candidate = timezone.to_s
          return Result.new(false, "apex.app.preferences.timezones.invalid") unless SELECTABLE_TIMEZONES.any? { |identifier| identifier.casecmp?(candidate) }

          zone = resolve_timezone(candidate)
          return Result.new(false, "apex.app.preferences.timezones.invalid") unless zone

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
            "tz" => normalize_timezone_for_cookie
          }.compact.presence || DEFAULT_QUERY_PREFERENCES
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
            DEFAULT_QUERY_PREFERENCES["ri"]
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
            DEFAULT_QUERY_PREFERENCES["tz"]
          end
        end
      end
    end
  end
end
