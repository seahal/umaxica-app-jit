# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Preference
      class RegionsController < ApplicationController
        def edit
          set_region_preferences_edit
        end

        def update
          set_region_preferences_update
          redirect_to(
            edit_sign_com_preference_region_url(
              ri: option_id_to_region(@preference_region.option_id, preference_prefix),
            ),
            notice: t("apex.com.preferences.update_success"),
          )
        end
      end
    end
  end
end
