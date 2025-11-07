# frozen_string_literal: true

module Top
  module Org
    module Preference
      class RegionsController < ApplicationController
        include PreferenceRegions

        private

        def translation_scope
          "top.org.preferences"
        end

        def preference_region_edit_url
          edit_top_org_preference_region_url
        end
      end
    end
  end
end
