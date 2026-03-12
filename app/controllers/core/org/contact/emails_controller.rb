# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Contact
      class EmailsController < Core::Org::ApplicationController
        include ::RateLimit

        before_action :set_contact

        def new
          render plain: placeholder_message(:new)
        end

        def create
          render plain: placeholder_message(:create), status: :created
        end

        private

        def set_contact
          contact_id = params[:contact_id]
          return render plain: "Contact ID is required", status: :bad_request if contact_id.blank?

          @contact = OrgContact.find_by(public_id: contact_id)
          return if @contact

          render plain: "Contact not found", status: :not_found
        end

        def placeholder_message(action)
          "Org contact email #{action} pending for contact #{@contact.id}"
        end
      end
    end
  end
end
