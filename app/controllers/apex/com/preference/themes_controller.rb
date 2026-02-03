# frozen_string_literal: true

module Apex
  module Com
    module Preference
      class ThemesController < ApplicationController
        include ::Preference::Core

        def edit
          set_colortheme_preferences_edit
        end

        def update
          set_colortheme_preferences_update
          redirect_to edit_apex_com_preference_theme_url(
            ct: colortheme_short_code(option_id_to_colortheme(@preference_colortheme.option_id, preference_prefix)),
          ),
                      notice: t("apex.com.preferences.update_success")
        end
      end
    end
  end
end
