# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Org
        module Preference
          class RegionsController < ApplicationController
            public_strict!
            include ::Preference::Core

            activate_preference_core

            def edit
              set_region_preferences_edit
            end

            def update
              set_region_preferences_update
              redirect_to(
                identity.edit_sign_org_preference_region_url(
                  ri: option_id_to_region(@preference_region.option_id, preference_prefix),
                ),
                notice: t("acme.org.preferences.update_success"),
              )
            end

            private

            def translation_scope
              "acme.org.preferences"
            end

            def preference_region_edit_url(params = {})
              identity.edit_sign_org_preference_region_url(params)
            end
          end
        end
      end
    end
  end
end
