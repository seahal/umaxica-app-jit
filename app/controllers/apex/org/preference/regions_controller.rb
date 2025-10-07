module Apex
  module Org
    module Preference
      class RegionsController < ApplicationController
        SELECTABLE_LANGUAGES = %w[JA EN].freeze
        DEFAULT_LANGUAGE = "JA"
        SELECTABLE_REGIONS = %w[JP US].freeze
        DEFAULT_REGION = "JP"
        SELECTABLE_TIMEZONES = %w[UTC America/New_York Asia/Tokyo].freeze
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
            flash[:notice] = t("messages.region_settings_updated_successfully") if result.updated?
            redirect_to edit_apex_org_preference_region_url
          end
        end

        private

        def set_edit_variables
          @current_region = session[:region] || DEFAULT_REGION
          @current_language = session[:language] || DEFAULT_LANGUAGE

          timezone = resolve_timezone(session[:timezone]) || resolve_timezone(DEFAULT_TIMEZONE)
          @current_timezone = timezone ? timezone.to_s : DEFAULT_TIMEZONE
        end

        def preference_params
          params.permit(:region, :language, :timezone)
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
            return Result.new(false, "apex.org.preferences.languages.unsupported")
          end

          session[:language] = normalized
          Result.new(true, nil)
        end

        def update_timezone(timezone)
          zone = resolve_timezone(timezone)
          return Result.new(false, "apex.org.preferences.timezones.invalid") unless zone

          session[:timezone] = zone_identifier(zone, timezone)
          Result.new(true, nil)
        end

        def valid_timezone?(timezone)
          resolve_timezone(timezone).present?
        end

        def language_name(code)
          {
            "EN" => "English",
            "JA" => "日本語"
          }[code] || code
        end

        def admin_timezones
          # Common admin timezones for global operations
          SELECTABLE_TIMEZONES.filter_map { |identifier| resolve_timezone(identifier) }
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
      end
    end
  end
end
