# frozen_string_literal: true

module Sign
  module Org
    class OutsController < ApplicationController
      before_action :authenticate!

      def edit
      end

      def destroy
        log_out
        redirect_to sign_org_root_path, notice: t(".destroy.success")
      end
    end
  end
end
