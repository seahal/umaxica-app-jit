module Peak
  module Org
    module Preference
      class RegionsController < ApplicationController
        include PreferenceRegions

        private

          def translation_scope
            "apex.org.preferences"
          end

          def preference_region_edit_url(params = {})
            edit_peak_org_preference_region_url(params)
          end
      end
    end
  end
end
