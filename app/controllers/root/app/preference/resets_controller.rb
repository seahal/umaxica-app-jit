module Root
  module App
    module Preference
      class ResetsController < ApplicationController
        ACCEPTANCE_COOKIE_KEYS = %i[
          accept_functional_cookies
          accept_performance_cookies
          accept_targeting_cookies
        ].freeze
        PREFERENCE_COOKIE_KEY = :root_app_preferences

        def edit
          @confirm_reset = params[:confirm_reset]
        end

        def destroy
          if reset_confirmed?
            clear_preference_cookies!
            flash[:notice] = t("root.app.preference.reset.destroy.success")
            redirect_to root_app_preference_path
          else
            @confirm_reset = params[:confirm_reset]
            flash.now[:alert] = t("root.app.preference.reset.destroy.confirmation_required")
            render :edit, status: :unprocessable_content
          end
        end

        private

        def reset_confirmed?
          ActiveModel::Type::Boolean.new.cast(params[:confirm_reset])
        end

        def clear_preference_cookies!
          ACCEPTANCE_COOKIE_KEYS.each { |key| cookies.delete(key) }
          cookies.delete(PREFERENCE_COOKIE_KEY)
        end
      end
    end
  end
end
