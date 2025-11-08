# frozen_string_literal: true

module Top
  module App
    module Preference
      class EmailsController < ApplicationController
        include PreferenceRegions

        private

        def translation_scope
          "top.app.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_top_app_preference_region_url(params)
        end
      end
    end
  end
end
