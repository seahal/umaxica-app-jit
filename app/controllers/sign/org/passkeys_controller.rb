# frozen_string_literal: true

module Sign
  module Org
    class PasskeysController < ApplicationController
      def new
        @staff_telephone = StaffTelephone.new
      end

      def edit
        @staff_telephone = StaffTelephone.new
      end

      def create
        render plain: t("sign.org.authentication.telephone.create.you_have_already_logged_in"),
               status: :bad_request and return if logged_in?

        head :ok
      end

      def update
        render plain: t("sign.org.authentication.telephone.create.you_have_already_logged_in"),
               status: :bad_request and return if logged_in?

        head :ok
      end
    end
  end
end
