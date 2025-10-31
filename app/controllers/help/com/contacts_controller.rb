module Help
  module Com
    class ContactsController < ApplicationController
      def new
        @service_site_contact = ServiceSiteContact.new
      end

      def create
      end

      def show
      end
    end
  end
end
