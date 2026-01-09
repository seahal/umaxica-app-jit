# frozen_string_literal: true

module Apex
  module Org
    module Preference
      class RegionsController < ApplicationController
        include ::Preference::Core

        def edit
          set_region_preferences_edit
        end

        def update
          set_region_preferences_update
          redirect_to edit_apex_org_preference_region_url(ri: @preference_region.option_id.downcase),
                      notice: t("apex.org.preferences.update_success")
        end

        private

        def translation_scope
          "apex.org.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_apex_org_preference_region_url(params)
        end
      end
    end
  end
end
