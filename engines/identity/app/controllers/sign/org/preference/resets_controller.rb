# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Org
        module Preference
          class ResetsController < ApplicationController
            public_strict!
            include ::Preference::Core

            activate_preference_core

            def edit
              @preference = @preferences
            end

            def destroy
              @preference = @preferences
              @preference.require_reset_confirmation(params[:confirm_reset])

              unless @preference.valid?(:reset)
                render :edit, status: :unprocessable_content
                return
              end

              reset_preference_to_defaults!

              # Preserve ri parameter on redirect
              redirect_params = {}
              redirect_params[:ri] = params[:ri] if params[:ri].present?

              redirect_to(
                identity.edit_sign_org_preference_reset_path(redirect_params),
                notice: t("acme.org.preference.resets.destroyed"),
              )
            end
          end
        end
      end
    end
  end
end
