# typed: false
# frozen_string_literal: true

module Email
  module Com
    class PreferenceMailer < ApplicationMailer
      def update_request
        @preference_request = params.fetch(:preference_request)
        @edit_url = params.fetch(:edit_url)

        mail(
          to: @preference_request.address,
          subject: t("email.com.preference_mailer.update_request.subject"),
        )
      end
    end
  end
end
