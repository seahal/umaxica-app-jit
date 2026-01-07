# frozen_string_literal: true

module Sign
  module Org
    class OutsController < ApplicationController
      include Sign::SessionVerification

      before_action :verify_session_staff

      def edit
      end

      def destroy
        session.delete(:staff)
        redirect_to sign_org_root_path, notice: t(".destroy.success")
      end
    end
  end
end
