module Help
  module Org
    class ContactsController < ApplicationController
      def new
        @contact_categories = OrgContactCategory.order(:title)
        render plain: "org contact form placeholder"
      end

      def create
        render plain: "org contact create placeholder", status: :created
      end
    end
  end
end
