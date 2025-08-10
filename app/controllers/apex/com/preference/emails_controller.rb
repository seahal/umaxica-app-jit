module Apex
  module Com
    module Preference
      class EmailsController < ApplicationController
        def edit
          @email_preferences = {
            newsletter: true,
            product_updates: true,
            security_alerts: true,
            promotional: false
          }
        end

        def update
          email_params = params.permit(:newsletter, :product_updates, :security_alerts, :promotional)
          
          if email_params.present?
            flash[:notice] = "Email preferences updated successfully"
            redirect_to edit_apex_com_preference_email_path
          else
            flash[:alert] = "No preferences selected"
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
