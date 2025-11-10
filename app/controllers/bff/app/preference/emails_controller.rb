# frozen_string_literal: true

module Bff
  module App
    module Preference
      class EmailsController < ApplicationController
        include PreferenceRegions

        private

        def translation_scope
          "bff.app.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_bff_app_preference_email_url(params)
        end
      end
    end
  end
end
