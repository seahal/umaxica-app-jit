module Auth
  module App
    module Authentication
      class EmailsController < ApplicationController
        def new
          render plain: t("www.app.authentication.email.new.you_have_already_logged_in"), status: 400 and return if logged_in_user?

          # set cookie with private key of htop
          cookies.encrypted[:htop_private_key] = {
            value: 1000,
            httponly: true,
            secure: Rails.env.production? ? true : false,
            expires: 10.minutes.from_now
          }

          @user_email = UserEmail.new
        end

        def create
          render plain: t("www.app.authentication.email.create.you_have_already_logged_in"), status: 400 and return if logged_in_user?

          if cookies.encrypted[:htop_private_key]
            render plain: "aaa"
          end
        end
      end
    end
  end
end
