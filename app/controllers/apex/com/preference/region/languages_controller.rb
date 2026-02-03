# frozen_string_literal: true

module Apex
  module Com
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
            session[:language] =
              option_id_to_language(
                @preference_language.option_id,
                preference_prefix,
              ) if @preference_language.option_id.present?
            redirect_to edit_apex_com_preference_region_language_url(
              lx: option_id_to_language(
                @preference_language.option_id, preference_prefix,
              ),
            )
          end
        end
      end
    end
  end
end
