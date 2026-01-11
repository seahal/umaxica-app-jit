# frozen_string_literal: true

module Apex
  module App
    module Preference
      module Region
        class LanguagesController < ApplicationController
          include ::Preference::Core

          def edit
            set_language_preferences_edit
          end

          def update
            set_language_preferences_update
            # Update session to apply language change immediately
            session[:language] = @preference_language.option_id.downcase if @preference_language.option_id.present?
            redirect_to edit_apex_app_preference_region_language_url(lx: @preference_language.option_id.downcase),
                        notice: t("apex.app.preferences.update_success")
          end
        end
      end
    end
  end
end
