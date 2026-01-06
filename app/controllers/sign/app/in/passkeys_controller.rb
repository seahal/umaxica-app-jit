# frozen_string_literal: true

module Sign
  module App
    module In
      class PasskeysController < ApplicationController
        def new
          @user_telephone = UserTelephone.new
        end

        def edit
          @user_telephone = UserTelephone.new
        end

        def create
          render plain: t("sign.app.authentication.telephone.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          head :ok
        end

        def update
          render plain: t("sign.app.authentication.telephone.create.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          head :ok
        end
      end
    end
  end
end
