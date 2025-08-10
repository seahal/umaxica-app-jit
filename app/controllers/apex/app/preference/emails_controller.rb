module Apex
  module App
    module Preference
      class EmailsController < ApplicationController
        def edit
          @email_preferences = {
            notifications: true,
            marketing: false,
            security_alerts: true
          }
        end

        def update
          email_params = params.permit(:notifications, :marketing, :security_alerts)
          
          if email_params.present?
            flash[:notice] = "Email preferences updated successfully"
            redirect_to edit_apex_app_preference_email_path
          else
            flash[:alert] = "Invalid email preferences"
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
