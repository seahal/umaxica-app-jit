# frozen_string_literal: true

module Sign
  module App
    module In
      class PasskeysController < ApplicationController
        include Auth::PreAuthenticationGuards

        def new
          @user_telephone = UserTelephone.new
        end

        def edit
          @user_telephone = UserTelephone.new
        end

        def create
          return if reject_if_logged_in("sign.app.authentication.telephone.create.you_have_already_logged_in")

          head :ok
        end

        def update
          return if reject_if_logged_in("sign.app.authentication.telephone.create.you_have_already_logged_in")

          head :ok
        end
      end
    end
  end
end
