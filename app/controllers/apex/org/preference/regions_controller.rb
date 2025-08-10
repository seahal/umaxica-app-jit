module Apex
  module Org
    module Preference
      class RegionsController < ApplicationController
        ADMIN_LANGUAGES = %w[en ja es fr de zh ko].freeze

        def edit
          set_edit_variables
        end

        def update
          updated_settings = []

          if params[:region].present?
            session[:region] = params[:region]
            updated_settings << "region"
          end

          if params[:country].present?
            session[:country] = params[:country]
            updated_settings << "country"
          end

          if params[:language].present?
            language_code = params[:language]
            if ADMIN_LANGUAGES.include?(language_code)
              session[:admin_language] = language_code
              updated_settings << "language"
            else
              flash[:alert] = I18n.t("apex.org.preferences.languages.unsupported")
              set_edit_variables
              render :edit, status: :unprocessable_content
              return
            end
          end

          if params[:timezone].present?
            timezone = params[:timezone]
            if ActiveSupport::TimeZone[timezone].present?
              session[:admin_timezone] = timezone
              updated_settings << "timezone"
            else
              flash[:alert] = I18n.t("apex.org.preferences.timezones.invalid")
              set_edit_variables
              render :edit, status: :unprocessable_content
              return
            end
          end

          if updated_settings.any?
            flash[:notice] = t("messages.region_settings_updated_successfully")
          end

          redirect_to apex_org_preference_url
        end

        private

        def set_edit_variables
          @region = session[:region] || "US"
          @country = session[:country] || "US"
          @current_language = session[:admin_language] || "en"
          @current_timezone = session[:admin_timezone] || "UTC"

          @available_languages = ADMIN_LANGUAGES.map do |lang|
            [ lang, language_name(lang) ]
          end

          @available_timezones = admin_timezones.map do |tz|
            [ tz.name, tz.to_s ]
          end.sort_by { |tz| tz.last }
        end

        def language_name(code)
          {
            "en" => "English (Admin)",
            "ja" => "日本語 (管理)",
            "es" => "Español (Admin)",
            "fr" => "Français (Admin)",
            "de" => "Deutsch (Admin)",
            "zh" => "中文 (管理)",
            "ko" => "한국어 (관리)"
          }[code] || code
        end

        def admin_timezones
          # Common admin timezones for global operations
          [
            ActiveSupport::TimeZone["UTC"],
            ActiveSupport::TimeZone["America/New_York"],
            ActiveSupport::TimeZone["Europe/London"],
            ActiveSupport::TimeZone["Europe/Paris"],
            ActiveSupport::TimeZone["Asia/Tokyo"],
            ActiveSupport::TimeZone["Asia/Shanghai"],
            ActiveSupport::TimeZone["Australia/Sydney"],
            ActiveSupport::TimeZone["America/Los_Angeles"]
          ].compact
        end
      end
    end
  end
end
