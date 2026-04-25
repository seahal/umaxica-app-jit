# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Preference
      class EmailsController < ApplicationController
        public_strict!
        include ::Preference::EmailActions

        private

        def audience_name
          "com"
        end

        def preference_mailer_class
          Email::Com::PreferenceMailer
        end

        def find_email_record_by_address(email)
          find_email_with_timing_protection(email)
        end

        def identity_email_model
          CustomerEmail
        end

        def preference_email_new_path
          identity.new_sign_com_preference_email_path(ri: params[:ri])
        end

        def preference_email_edit_url(token)
          identity.edit_sign_com_preference_email_url(token: token, ri: params[:ri])
        end
      end
    end
  end
end
