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
        @preference_email_path = sign_app_preference_email_index_path
      end
    end
  end
end
