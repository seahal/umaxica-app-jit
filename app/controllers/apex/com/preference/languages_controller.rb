# frozen_string_literal: true

module Apex
  module Com
    module Preference
      class LanguagesController < ApplicationController
        include ::Preference::Core

        def edit
          set_language_preferences_edit
        end

        def update
          set_language_preferences_update
          redirect_to edit_apex_com_preference_language_url(lx: @preference_language.option_id.downcase),
                      notice: t("apex.com.preferences.update_success")
        end
      end
    end
  end
end
