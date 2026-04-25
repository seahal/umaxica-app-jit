# typed: false
# frozen_string_literal: true

module Sign
  module App
    class PreferencesController < ApplicationController
      before_action :set_email_path

      def show
      end

      private

      def set_email_path
        @preference_email_path = identity.new_sign_app_preference_email_path
      end
    end
  end
end
