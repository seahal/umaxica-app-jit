# frozen_string_literal: true

module Apex
  module App
    module Preference
      class ResetsController < ApplicationController
        def destroy
          # Clear all user preferences (theme, region, language, timezone, cookies)
          session.delete(:theme)
          session.delete(:region_code)
          session.delete(:language)
          session.delete(:timezone)
          cookies.delete(:cookie_preferences)

          redirect_to apex_app_preference_path, notice: t("apex.app.preference.resets.destroyed")
        end
      end
    end
  end
end
