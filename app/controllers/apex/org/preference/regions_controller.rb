module Apex
  module Org
    module Preference
      class RegionsController < ApplicationController
        def edit
          @region = session[:region] || "US"
          @country = session[:country] || "US"
        end

        def update
          session[:region] = params[:region] if params[:region].present?
          session[:country] = params[:country] if params[:country].present?

          redirect_to apex_org_preference_url, notice: t("messages.region_settings_updated_successfully")
        end
      end
    end
  end
end
