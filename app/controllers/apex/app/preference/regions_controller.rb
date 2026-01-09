# frozen_string_literal: true

module Apex
  module App
    module Preference
      class RegionsController < ApplicationController
        include ::Preference::Core

        def edit
          set_region_preferences_edit
        end

        def update
          set_region_preferences_update
          redirect_to edit_apex_app_preference_region_url(ri: @preference_region.option_id.downcase),
                      notice: t("apex.app.preferences.update_success")
        end
      end
    end
  end
end
