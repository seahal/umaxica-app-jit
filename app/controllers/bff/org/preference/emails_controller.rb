# frozen_string_literal: true

module Bff
  module Org
    module Preference
      class EmailsController < ApplicationController
        def edit
          # For now, we'll just render the edit view
          # In a real app, you'd load the email preference from database
          @email_preference = { id: params[:id], enabled: true }
        end

        def update
          # In a real app, you'd update the email preference in database
          # For now, just flash a success message

          redirect_to bff_org_preference_path, notice: t("bff.org.preference.emails.updated")
        end
      end
    end
  end
end
