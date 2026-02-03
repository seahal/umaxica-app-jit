# frozen_string_literal: true

module Apex
  module Org
    module Preference
      module Region
        class TimezonesController < ApplicationController
          public_strict!
          include ::Preference::Core

          def edit
            set_timezone_preferences_edit
          end

          def update
            set_timezone_preferences_update
            redirect_to(
              edit_apex_org_preference_region_timezone_url(
                tz: option_id_to_timezone(@preference_timezone.option_id, preference_prefix).downcase,
              ),
              notice: t("apex.org.preferences.update_success"),
            )
          rescue PreferenceOperationError
            redirect_to edit_apex_org_preference_region_timezone_url,
                        alert: I18n.t("errors.messages.preference_operation_failed")
          end
        end
      end
    end
  end
end
