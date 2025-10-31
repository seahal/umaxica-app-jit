module Help
module Com
    class ContactsController < ApplicationController
      def new
        @site_contact = CorporateSiteContact.new
      end

      def create
      end

      def show
      end
    end
  end
end
