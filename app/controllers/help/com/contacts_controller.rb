module Help
  module Com
    class ContactsController < ApplicationController
      def new
        @service_site_contact = ServiceSiteContact.new
        @contact_categories = ContactCategory.order(:title)
      end

      def create
      end
      
      def show
      end
    end
  end
end
