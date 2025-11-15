module Sign
  module App
    module Authentication
      class EmailsController < ApplicationController
        def new
          render plain: t("sign.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          # set cookie with private key of htop
          cookies.encrypted[:htop_private_key] = {
            value: 1000,
            httponly: true,
            secure: Rails.env.production? ? true : false,
            expires: 10.minutes.from_now
          }

          @user_email = UserIdentityEmail.new
        end

        def create
          render plain: t("sign.app.authentication.email.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          if cookies.encrypted[:htop_private_key]
            render plain: "aaa"
          end
        end
      end
    end
  end
end
