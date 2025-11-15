module Help
  module App
    class ContactsController < ApplicationController
      def new
        @contact_categories = AppContactCategory.order(:title)
        render plain: "service contact form placeholder"
      end

      def create
        render plain: "service contact create placeholder", status: :created
      end
    end
  end
end
