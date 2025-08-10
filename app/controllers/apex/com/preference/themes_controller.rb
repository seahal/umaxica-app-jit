module Apex
  module Com
    module Preference
      class ThemesController < ApplicationController
        AVAILABLE_THEMES = %w[light dark corporate].freeze

        def edit
          set_edit_variables
        end

        def update
          theme = params[:theme]
          
          if AVAILABLE_THEMES.include?(theme)
            session[:theme] = theme
            flash[:notice] = "Corporate theme updated to #{theme.humanize}"
            redirect_to edit_apex_com_preference_theme_path
          else
            flash[:alert] = "Invalid theme selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_theme = session[:theme] || "corporate"
          @available_themes = AVAILABLE_THEMES.map do |theme|
            { value: theme, name: theme_display_name(theme) }
          end
        end

        def theme_display_name(theme)
          {
            "light" => "Light Theme",
            "dark" => "Dark Theme", 
            "corporate" => "Corporate Theme"
          }[theme] || theme.humanize
        end
      end
    end
  end
end
