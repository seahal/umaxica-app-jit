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

        def update
          redirect_to(new_sign_org_social_session_path(provider: "google_org", ri: params[:ri]))
        end

        def destroy
          redirect_to(
            sign_org_configuration_emails_path(ri: params[:ri]),
            alert: t("sign.org.configuration.google.destroy.via_email"),
          )
        end
      end
    end
  end
end
