module Apex
  module Org
    module Preference
      class TimezonesController < ApplicationController
        def edit
          set_edit_variables
        end

        def update
          timezone = params[:timezone]
          
          if timezone.present? && ActiveSupport::TimeZone[timezone].present?
            session[:admin_timezone] = timezone
            flash[:notice] = "Admin timezone updated to #{ActiveSupport::TimeZone[timezone]}"
            redirect_to edit_apex_org_preference_timezone_path
          else
            flash[:alert] = "Invalid timezone selected for admin interface"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_timezone = session[:admin_timezone] || "UTC"
          @available_timezones = admin_timezones.map do |tz|
            { identifier: tz.name, name: tz.to_s }
          end.sort_by { |tz| tz[:name] }
        end

        def admin_timezones
          # Common admin timezones for global operations
          [
            ActiveSupport::TimeZone["UTC"],
            ActiveSupport::TimeZone["America/New_York"],
            ActiveSupport::TimeZone["Europe/London"],
            ActiveSupport::TimeZone["Europe/Paris"],
            ActiveSupport::TimeZone["Asia/Tokyo"],
            ActiveSupport::TimeZone["Asia/Shanghai"],
            ActiveSupport::TimeZone["Australia/Sydney"],
            ActiveSupport::TimeZone["America/Los_Angeles"]
          ].compact
        end
      end
    end
  end
end
