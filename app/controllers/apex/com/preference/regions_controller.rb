module Apex
  module Com
    module Preference
      class RegionsController < ApplicationController
        SUPPORTED_LANGUAGES = %w[en ja es fr de zh].freeze

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
            if SUPPORTED_LANGUAGES.include?(language_code)
              session[:language] = language_code
              updated_settings << "language"
            else
              flash[:alert] = I18n.t("apex.com.preferences.languages.unsupported")
              set_edit_variables
              render :edit, status: :unprocessable_content
              return
            end
          end

          if params[:timezone].present?
            timezone = params[:timezone]
            if ActiveSupport::TimeZone[timezone].present?
              session[:timezone] = timezone
              updated_settings << "timezone"
            else
              flash[:alert] = I18n.t("apex.com.preferences.timezones.invalid")
              set_edit_variables
              render :edit, status: :unprocessable_content
              return
            end
          end

          if updated_settings.any?
            flash[:notice] = t("messages.region_settings_updated_successfully")
          end

          redirect_to apex_com_preference_url
        end

        private

        def set_edit_variables
          @region = session[:region] || "US"
          @country = session[:country] || "US"
          @current_language = session[:language] || "en"
          @current_timezone = session[:timezone] || "UTC"

          @available_languages = SUPPORTED_LANGUAGES.map do |lang|
            [ lang, language_name(lang) ]
          end

          @available_timezones = ActiveSupport::TimeZone.all.map do |tz|
            [ tz.name, tz.to_s ]
          end.sort_by { |tz| tz.last }
        end

        def language_name(code)
          {
            "en" => "English",
            "ja" => "日本語",
            "es" => "Español",
            "fr" => "Français",
            "de" => "Deutsch",
            "zh" => "中文"
          }[code] || code
        end
      end
    end
  end
end
