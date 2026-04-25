# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Preference
      module Region
        class TimezonesController < ApplicationController
          public_strict!
          include ::Preference::Core

          activate_preference_core

          def edit
            set_timezone_preferences_edit
          end

          def update
            set_timezone_preferences_update
            session[:timezone] = option_id_to_timezone(@preference_timezone.option_id, preference_prefix)
            redirect_to(
              identity.edit_sign_com_preference_region_timezone_url,
              notice: t("acme.com.preferences.update_success"),
            )
          rescue PreferenceOperationError
            redirect_to(
              identity.edit_sign_com_preference_region_timezone_url,
              alert: I18n.t("errors.messages.preference_operation_failed"),
            )
          end
        end
      end
    end
  end
end
