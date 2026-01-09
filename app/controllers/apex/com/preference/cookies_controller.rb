# frozen_string_literal: true

module Apex
  module Com
    module Preference
      class CookiesController < ApplicationController
        include ::Preference::Core

        def edit
          set_cookie_preferences_edit
        end

        def update
          set_cookie_preferences_update
          redirect_to edit_apex_com_preference_cookie_url, notice: t("apex.com.preferences.update_success")
        end
      end
    end
  end
end
