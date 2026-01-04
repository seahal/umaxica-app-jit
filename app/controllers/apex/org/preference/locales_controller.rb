# frozen_string_literal: true

module Apex
  module Org
    module Preference
      class LocalesController < ApplicationController
        include PreferenceLocales

        private

        def translation_scope
          "apex.org.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_apex_org_preference_locale_url(params)
        end
      end
    end
  end
end
