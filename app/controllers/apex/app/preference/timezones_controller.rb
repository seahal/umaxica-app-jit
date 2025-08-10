module Apex
  module App
    module Preference
      class TimezonesController < ApplicationController
        def edit
          set_edit_variables
        end

        def update
          timezone = params[:timezone]
          
          if timezone.present? && ActiveSupport::TimeZone[timezone].present?
            session[:timezone] = timezone
            flash[:notice] = "Timezone updated to #{ActiveSupport::TimeZone[timezone]}"
            redirect_to edit_apex_app_preference_timezone_path
          else
            flash[:alert] = "Invalid timezone selected"
            set_edit_variables
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_edit_variables
          @current_timezone = session[:timezone] || "UTC"
          @available_timezones = ActiveSupport::TimeZone.all.map do |tz|
            { identifier: tz.name, name: tz.to_s }
          end.sort_by { |tz| tz[:name] }
        end
      end
    end
  end
end
