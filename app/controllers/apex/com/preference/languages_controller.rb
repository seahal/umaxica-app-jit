module Apex
  module Com
    module Preference
      class LanguagesController < ApplicationController
        SUPPORTED_LANGUAGES = %w[en ja es fr de zh].freeze

        def edit
          set_edit_variables
        end

        def update
          language_code = params[:language]
          
          if SUPPORTED_LANGUAGES.include?(language_code)
            session[:language] = language_code
            flash[:notice] = "Language preference updated to #{language_name(language_code)}"
            redirect_to edit_apex_com_preference_language_path
          else
            flash[:alert] = "Unsupported language selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_language = session[:language] || "en"
          @available_languages = SUPPORTED_LANGUAGES.map do |lang|
            { code: lang, name: language_name(lang) }
          end
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
