module Help
  module Org
    class ContactsController < ApplicationController
      before_action :set_contact, only: %i[show edit]

      def show; end

      def new
        @contact = OrgContact.new
        @contact_categories = OrgContactCategory.order(:title)
        render plain: "org contact form placeholder"
      end


      def edit
        @contact_categories = OrgContactCategory.order(:title)
      end

      def create
        render plain: "org contact create placeholder", status: :created
      end

      private

      def set_contact
        @contact = OrgContact.find_by!(public_id: params[:id])
      end
    end
  end
end
