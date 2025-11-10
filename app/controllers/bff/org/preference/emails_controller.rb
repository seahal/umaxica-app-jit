# frozen_string_literal: true

module Bff
  module Org
    module Preference
      class EmailsController < ApplicationController
        include ::Bff::Preference::EmailFlow

        private

        def preference_context
          :org
        end

        def preference_email_edit_url(token)
          edit_bff_org_preference_email_url(token, host: request.host, port: request.port, protocol: request.protocol)
        end

        def preference_mailer
          Email::Org::PreferenceMailer
        end
      end
    end
  end
end
