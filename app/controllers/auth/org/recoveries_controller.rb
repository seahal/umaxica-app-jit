# frozen_string_literal: true

module Auth
  module Org
    class RecoveriesController < ApplicationController
      def new
        @staff_recover_code = RecoveryForm.new
      end

      def create
        @staff_recover_code = RecoveryForm.new(recovery_params)
        render :new, status: :unprocessable_content
      end

      private

      def recovery_params
        params.fetch(:recovery_form, {}).permit(:account_identifiable_information, :recovery_code)
      end

      class RecoveryForm
        include ActiveModel::Model

        attr_accessor :account_identifiable_information, :recovery_code
      end
    end
  end
end
