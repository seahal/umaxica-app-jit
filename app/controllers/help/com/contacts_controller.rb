module Help
  module Com
    class ContactsController < ApplicationController
      def show
      end

      def new
        @service_site_contact = ServiceSiteContact.new
        @contact_categories = ContactCategory.order(:title)
      end


      def create
      end
    end
  end
end
