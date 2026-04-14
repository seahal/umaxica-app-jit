# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Preference
      class CookiesController < ApplicationController
        public_strict!
        include ::Preference::Core

        activate_preference_core

        def edit
          set_cookie_preferences_edit
        end

        def update
          set_cookie_preferences_update
          return render_preference_update_response if request.format.json?

          redirect_params = {}
          ::Preference::Global::PARAM_CONTEXT_KEYS.each do |key|
            redirect_params[key] = params[key] if params[key].present?
          end
          redirect_to(
            edit_sign_org_preference_cookie_url(redirect_params),
            notice: t("apex.org.preferences.update_success"),
          )
        end
      end
    end
  end
end
