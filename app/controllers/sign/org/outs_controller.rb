# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class OutsController < ApplicationController
      auth_required!
      before_action :authenticate!

      def edit
      end

      def destroy
        log_out
        redirect_to sign_org_root_path, notice: t(".success")
      end
    end
  end
end
