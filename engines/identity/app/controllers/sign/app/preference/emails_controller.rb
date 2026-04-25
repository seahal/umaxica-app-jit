# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        module Preference
          class EmailsController < ApplicationController
            public_strict!
            include ::Preference::EmailActions

            private

            def audience_name
              "app"
            end

            def preference_mailer_class
              Email::App::PreferenceMailer
            end

            def find_email_record_by_address(email)
              find_email_with_timing_protection(email)
            end

            def preference_email_new_path
              identity.new_sign_app_preference_email_path
            end

            def preference_email_edit_url(token)
              identity.edit_sign_app_preference_email_url(token: token)
            end
          end
        end
      end
    end
  end
end
