# frozen_string_literal: true

module Apex
  module App
    module Preference
      class TimezonesController < ApplicationController
        include ::Preference::Core

        def edit
          set_timezone_preferences_edit
        end

        def update
          set_timezone_preferences_update
          redirect_to edit_apex_app_preference_timezone_url(tz: @preference_timezone.option_id.downcase),
                      notice: t("apex.app.preferences.update_success")
        rescue PreferenceOperationError
          redirect_to edit_apex_app_preference_timezone_url,
                      alert: I18n.t("errors.messages.preference_operation_failed")
        end
      end
    end
  end
end
