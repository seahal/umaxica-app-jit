module Help
  module App
    module Contact
      class EmailsController < ApplicationController
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

            @contact = AppContact.find_by(public_id: contact_id)
            if @contact.nil?
              raise StandardError, "Contact not found"
            end
          end

          def placeholder_message(action)
            "Service contact email #{action} pending for contact #{@contact.id}"
          end
      end
    end
  end
end
