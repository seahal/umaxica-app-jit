# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Preference
      class RegionsController < ApplicationController
        public_strict!
        include ::Preference::Core

        def edit
          set_region_preferences_edit
        end

        def update
          set_region_preferences_update
          redirect_to(
            edit_sign_app_preference_region_url(
              ri: option_id_to_region(@preference_region.option_id, preference_prefix),
            ),
            notice: t("apex.app.preferences.update_success"),
          )
        end
      end
    end
  end
end
