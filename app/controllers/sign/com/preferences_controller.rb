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
        @preference_email_path = sign_com_preference_email_index_path(ri: params[:ri])
      end
    end
  end
end
