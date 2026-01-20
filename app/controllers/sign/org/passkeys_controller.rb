# frozen_string_literal: true

module Sign
  module Org
    class PasskeysController < ApplicationController
      before_action :reject_logged_in_session

      def new
        @staff_telephone = StaffTelephone.new
      end

      def edit
        @staff_telephone = StaffTelephone.new
      end

      def create
        head :ok
      end

      def update
        head :ok
      end
    end
  end
end
