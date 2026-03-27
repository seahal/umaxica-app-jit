# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Preference
      class RegionsController < ApplicationController
        public_strict!
        include ::Preference::Core

        def edit
          set_region_preferences_edit
        end

        def update
          set_region_preferences_update
          redirect_to(
            edit_sign_org_preference_region_url(
              ri: option_id_to_region(@preference_region.option_id, preference_prefix),
            ),
            notice: t("apex.org.preferences.update_success"),
          )
        end

        private

        def translation_scope
          "apex.org.preferences"
        end

        def preference_region_edit_url(params = {})
          edit_sign_org_preference_region_url(params)
        end
      end
    end
  end
end
