module Sign
  module Org
    class RegistrationsController < ApplicationController
      def new
        @registration_methods = [
          {
            key: :email,
            path: new_sign_org_registration_email_path
          },
          {
            key: :telephone,
            path: new_sign_org_registration_telephone_path
          }
        ]
        @social_providers = [
          {
            key: :google,
            path: "/sign/google_oauth2",
            method: :post,
            data: { turbo: false }
          },
          {
            key: :apple,
            path: "/sign/apple",
            method: :post,
            data: { turbo: false
          } } ]
      end
    end
  end
end
