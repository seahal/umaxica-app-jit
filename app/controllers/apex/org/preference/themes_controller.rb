# typed: false
# frozen_string_literal: true

module Apex
  module Org
    module Preference
      class ThemesController < ApplicationController
        public_strict!
        include ::Preference::Core

        def edit
          set_colortheme_preferences_edit
        end

        def update
          set_colortheme_preferences_update
          redirect_to safe_return_to_path || edit_apex_org_preference_theme_url,
                      notice: t("apex.org.preferences.update_success")
        end
      end
    end
  end
end
