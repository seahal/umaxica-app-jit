module Apex
  module App
    module Preference
      class ThemesController < ApplicationController
        AVAILABLE_THEMES = %w[light dark auto].freeze

        def edit
          set_edit_variables
        end

        def update
          theme = params[:theme]
          
          if AVAILABLE_THEMES.include?(theme)
            session[:theme] = theme
            flash[:notice] = "Theme updated to #{theme.humanize}"
            redirect_to edit_apex_app_preference_theme_path
          else
            flash[:alert] = "Invalid theme selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_theme = session[:theme] || "light"
          @available_themes = AVAILABLE_THEMES.map do |theme|
            { value: theme, name: theme.humanize }
          end
        end
      end
    end
  end
end
