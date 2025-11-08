# frozen_string_literal: true

module Top
  module Com
    module Preference
      class ResetsController < ApplicationController
        def destroy
          # Clear all user preferences (theme, region, language, timezone, cookies)
          session.delete(:theme)
          session.delete(:region_code)
          session.delete(:language)
          session.delete(:timezone)
          cookies.delete(:cookie_preferences)

          redirect_to top_com_preference_path, notice: t("top.com.preference.resets.destroyed")
        end
      end
    end
  end
end
