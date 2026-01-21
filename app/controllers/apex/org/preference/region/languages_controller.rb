# frozen_string_literal: true

module Apex
  module Org
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
            session[:language] = @preference_language.option_id.downcase if @preference_language.option_id.present?
            redirect_to edit_apex_org_preference_region_language_url(lx: @preference_language.option_id.downcase),
                        notice: t("apex.org.preferences.update_success")
          end

          private

          def translation_scope
            "apex.org.preferences"
          end

          def preference_language_edit_url(params = {})
            edit_apex_org_preference_region_language_url(params)
          end
        end
      end
    end
  end
end
