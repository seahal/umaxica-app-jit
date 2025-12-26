# frozen_string_literal: true

module Peak
  module Com
    module Preference
      class LocalesController < ApplicationController
        include PreferenceLocales

        private

        def translation_scope
          "apex.com.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_peak_com_preference_locale_url(params)
        end
      end
    end
  end
end
