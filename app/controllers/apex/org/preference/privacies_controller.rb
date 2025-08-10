module Apex
  module Org
    module Preference
      class PrivaciesController < ApplicationController
        def edit
          @privacy_settings = {
            data_sharing: false,
            analytics_tracking: true,
            third_party_cookies: false,
            personalized_ads: false,
            data_retention: "6_months"
          }
        end

        def update
          privacy_params = params.permit(:data_sharing, :analytics_tracking, 
                                       :third_party_cookies, :personalized_ads, 
                                       :data_retention)
          
          if privacy_params.present? && valid_retention_period?
            flash[:notice] = "Privacy settings updated successfully"
            redirect_to edit_apex_org_preference_privacy_path
          else
            flash[:alert] = "Invalid privacy settings"
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def valid_retention_period?
          %w[1_month 3_months 6_months 1_year 2_years].include?(params[:data_retention])
        end
      end
    end
  end
end
