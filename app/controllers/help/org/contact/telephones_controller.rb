module Help
  module Org
    module Contact
      class TelephonesController < ApplicationController
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

            if contact_id.blank?
              raise StandardError, "Contact ID is required"
            end

            @contact = OrgContact.find_by(public_id: contact_id)
            if @contact.nil?
              raise StandardError, "Contact not found"
            end
          end

          def placeholder_message(action)
            "Org contact telephone #{action} pending for contact #{@contact.id}"
          end
      end
    end
  end
end
