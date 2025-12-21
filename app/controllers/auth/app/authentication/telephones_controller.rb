module Auth
  module App
    module Authentication
      class TelephonesController < ApplicationController
        def new
          @user_telephone = UserIdentityTelephone.new
        end

        def create
          render plain: t("auth.app.authentication.telephone.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          head :ok
        end
      end
    end
  end
end
