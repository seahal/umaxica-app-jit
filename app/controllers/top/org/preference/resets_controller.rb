# frozen_string_literal: true

module Top
  module Org
    module Preference
      class ResetsController < ApplicationController
        def destroy
          # Clear all user preferences (theme, region, language, timezone, cookies)
          session.delete(:theme)
          session.delete(:region_code)
          session.delete(:language)
          session.delete(:timezone)
          cookies.delete(:cookie_preferences)

          redirect_to top_org_preference_path, notice: t("top.org.preference.resets.destroyed")
        end
      end
    end
  end
end
