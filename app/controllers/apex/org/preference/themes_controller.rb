module Apex
  module Org
    module Preference
      class ThemesController < ApplicationController
        ADMIN_THEMES = %w[light dark admin high_contrast].freeze

        def edit
          set_edit_variables
        end

        def update
          theme = params[:theme]
          
          if ADMIN_THEMES.include?(theme)
            session[:admin_theme] = theme
            flash[:notice] = "Admin theme updated to #{theme_display_name(theme)}"
            redirect_to edit_apex_org_preference_theme_path
          else
            flash[:alert] = "Invalid admin theme selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_theme = session[:admin_theme] || "admin"
          @available_themes = ADMIN_THEMES.map do |theme|
            { value: theme, name: theme_display_name(theme) }
          end
        end

        def theme_display_name(theme)
          {
            "light" => "Light Admin Theme",
            "dark" => "Dark Admin Theme",
            "admin" => "Default Admin Theme",
            "high_contrast" => "High Contrast Theme"
          }[theme] || theme.humanize
        end
      end
    end
  end
end
