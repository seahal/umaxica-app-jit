# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Preference
      module Region
        class LanguagesController < ApplicationController
          public_strict!
          include ::Preference::Core

          def edit
            set_language_preferences_edit
          end

          def update
            set_language_preferences_update
            # Update session to apply language change immediately
            session[:language] =
              option_id_to_language(
                @preference_language.option_id,
                preference_prefix,
              ) if @preference_language.option_id.present?
            redirect_params = {}
            if params[:lx].present?
              redirect_params[:lx] =
                option_id_to_language(@preference_language.option_id, preference_prefix)
            end
            redirect_to(
              edit_sign_app_preference_region_language_url(redirect_params),
              notice: t("apex.app.preferences.update_success"),
            )
          end
        end
      end
    end
  end
end
