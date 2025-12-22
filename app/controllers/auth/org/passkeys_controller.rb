module Auth
  module Org
    class PasskeysController < ApplicationController
      def new
        @staff_telephone = StaffIdentityTelephone.new
      end

      def edit
        @staff_telephone = StaffIdentityTelephone.new
      end

      def create
        render plain: t("auth.org.authentication.telephone.create.you_have_already_logged_in"),
               status: :bad_request and return if logged_in?

        head :ok
      end

      def update
        render plain: t("auth.org.authentication.telephone.create.you_have_already_logged_in"),
               status: :bad_request and return if logged_in?

        head :ok
      end
    end
  end
end
