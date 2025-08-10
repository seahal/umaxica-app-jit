module Apex
  module Org
    module Preference
      class LanguagesController < ApplicationController
        ADMIN_LANGUAGES = %w[en ja es fr de zh ko].freeze

        def edit
          set_edit_variables
        end

        def update
          language_code = params[:language]
          
          if ADMIN_LANGUAGES.include?(language_code)
            session[:admin_language] = language_code
            flash[:notice] = "Admin language updated to #{language_name(language_code)}"
            redirect_to edit_apex_org_preference_language_path
          else
            flash[:alert] = "Unsupported admin language selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_language = session[:admin_language] || "en"
          @available_languages = ADMIN_LANGUAGES.map do |lang|
            { code: lang, name: language_name(lang) }
          end
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
      end
    end
  end
end
