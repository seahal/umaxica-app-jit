# frozen_string_literal: true

module Bff
  module App
    module Preference
      class EmailsController < ApplicationController
        include ::Bff::Preference::EmailFlow

        private

        def preference_context
          :app
        end

        def preference_email_edit_url(token)
          edit_bff_app_preference_email_url(token, host: request.host, port: request.port, protocol: request.protocol)
        end

        def preference_mailer
          Email::App::PreferenceMailer
        end
      end
    end
  end
end
