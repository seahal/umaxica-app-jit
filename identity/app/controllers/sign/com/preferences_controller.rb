# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class PreferencesController < Sign::Com::ApplicationController
      public_strict!
      before_action :set_email_path

      def show
      end

      private

      def set_email_path
        @preference_email_path = identity.new_sign_com_preference_email_path(ri: params[:ri])
      end
    end
  end
end
