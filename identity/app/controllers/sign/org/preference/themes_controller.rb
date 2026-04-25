# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Preference
      class ThemesController < ApplicationController
        public_strict!
        include ::Preference::Core

        activate_preference_core

        def edit
          set_colortheme_preferences_edit
        end

        def update
          set_colortheme_preferences_update
          return render_preference_update_response if request.format.json?

          redirect_to(
            safe_return_to_path || identity.edit_sign_org_preference_theme_url,
            notice: t("acme.org.preferences.update_success"),
          )
        end
      end
    end
  end
end
