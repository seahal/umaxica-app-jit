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
          @contact = OrgContact.find(params[:contact_id])
        end

        def placeholder_message(action)
          "Org contact telephone #{action} pending for contact #{@contact.id}"
        end
      end
    end
  end
end
