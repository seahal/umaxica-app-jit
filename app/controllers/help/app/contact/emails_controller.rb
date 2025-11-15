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
          @contact = AppContact.find(params[:contact_id])
        end

        def placeholder_message(action)
          "Service contact email #{action} pending for contact #{@contact.id}"
        end
      end
    end
  end
end
