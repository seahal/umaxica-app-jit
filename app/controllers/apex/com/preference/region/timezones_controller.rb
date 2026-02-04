# frozen_string_literal: true

module Apex
  module Com
    module Preference
      module Region
        class TimezonesController < ApplicationController
          include ::Preference::Core

          def edit
            set_timezone_preferences_edit
          end

          def update
            set_timezone_preferences_update
            redirect_params = {}
            if params[:tz].present?
              redirect_params[:tz] =
                option_id_to_timezone(@preference_timezone.option_id, preference_prefix).downcase
            end
            redirect_to edit_apex_com_preference_region_timezone_url(redirect_params)
          rescue PreferenceOperationError
            redirect_to edit_apex_com_preference_region_timezone_url,
                        alert: I18n.t("errors.messages.preference_operation_failed")
          end
        end
      end
    end
  end
end
