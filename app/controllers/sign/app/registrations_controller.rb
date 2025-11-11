module Sign
  module App
    class RegistrationsController < ApplicationController
      def new
        @registration_methods = [
          {
            key: :email,
            path: new_sign_app_registration_email_path
          },
          {
            key: :telephone,
            path: new_sign_app_registration_telephone_path
          }
        ]

        @social_providers = [
          {
            key: :google,
            path: "social/google_oauth2",
            method: :post,
            data: { turbo: false }
          },
          {
            key: :apple,
            path: "social/apple",
            method: :post,
            data: { turbo: false }
          }
        ]
      end
    end
  end
end
