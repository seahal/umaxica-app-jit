# frozen_string_literal: true

module Apex
  module App
    module Preference
      class ResetsController < ApplicationController
        include ::Preference::Core

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

          # delete_preference_cookie calls delete_preference_cookies which removes
          # jit_ct, jit_lx, jit_tz, and clears the preference auth cookie.
          delete_preference_cookie

          # Preserve ri parameter on redirect
          redirect_params = {}
          redirect_params[:ri] = params[:ri] if params[:ri].present?

          redirect_to edit_apex_app_preference_reset_path(redirect_params),
                      notice: t("apex.app.preference.resets.destroyed")
        end
      end
    end
  end
end
