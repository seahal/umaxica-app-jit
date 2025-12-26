# frozen_string_literal: true

module Email
  module Org
    class PreferenceMailer < ApplicationMailer
      def update_request
        @preference_request = params.fetch(:preference_request)
        @edit_url = params.fetch(:edit_url)

        mail to: @preference_request.email_address, subject: t("email.org.preference_mailer.update_request.subject")
      end
    end
  end
end
