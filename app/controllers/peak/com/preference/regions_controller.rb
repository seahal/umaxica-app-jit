# frozen_string_literal: true

module Peak
  module Com
    module Preference
      class RegionsController < ApplicationController
        include PreferenceRegions

        private

        def translation_scope
          "apex.com.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_peak_com_preference_region_url(params)
        end
      end
    end
  end
end
