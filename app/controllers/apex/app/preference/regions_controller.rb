# frozen_string_literal: true

module Apex
  module App
    module Preference
      class RegionsController < ApplicationController
        include PreferenceRegions

        private

        def translation_scope
          "apex.app.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_apex_app_preference_region_url(params)
        end
      end
    end
  end
end
