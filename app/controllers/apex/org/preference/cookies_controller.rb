# frozen_string_literal: true

module Apex
  module Org
    module Preference
      class CookiesController < ApplicationController
        public_strict!
        include ::Preference::Core

        def edit
          set_cookie_preferences_edit
        end

        def update
          set_cookie_preferences_update
          redirect_to edit_apex_org_preference_cookie_url, notice: t("apex.org.preferences.update_success")
        end
      end
    end
  end
end
