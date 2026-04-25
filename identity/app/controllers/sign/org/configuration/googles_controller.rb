# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class GooglesController < ApplicationController
        auth_required!

        before_action :authenticate_staff!

        def show
          @google_login_enabled = current_staff.staff_emails.exists?(
            staff_identity_email_status_id: [StaffEmailStatus::ACTIVE, StaffEmailStatus::VERIFIED],
          )
        end

        def create
          redirect_to(identity.new_sign_org_social_session_path(provider: "google_org", ri: params[:ri]))
        end
      end
    end
  end
end
