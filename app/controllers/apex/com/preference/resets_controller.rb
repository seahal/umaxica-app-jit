# frozen_string_literal: true

module Apex
  module Com
    module Preference
      class ResetsController < ApplicationController
        include ::Preference::Core

        def destroy
          delete_preference_cookie
          redirect_to edit_apex_com_preference_reset_path, notice: t("apex.com.preference.resets.destroyed")
        end
      end
    end
  end
end
