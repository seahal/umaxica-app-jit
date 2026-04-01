# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Preference
      class EmailsController < ApplicationController
        public_strict!
        include ::Preference::EmailActions

        private

        def audience_name
          "org"
        end

        def preference_mailer_class
          Email::Org::PreferenceMailer
        end

        def find_email_record_by_address(email)
          StaffEmail.find_by(address: email)
        end

        def preference_email_new_path
          new_sign_org_preference_email_path(ri: params[:ri])
        end

        def preference_email_edit_url(token)
          edit_sign_org_preference_email_url(token: token, ri: params[:ri])
        end
      end
    end
  end
end
