# typed: false
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
          redirect_params = {}
          ::Preference::Global::PARAM_CONTEXT_KEYS.each do |key|
            redirect_params[key] = params[key] if params[key].present?
          end
          redirect_to edit_apex_com_preference_cookie_url(redirect_params),
                      notice: t("apex.com.preferences.update_success")
        end
      end
    end
  end
end
