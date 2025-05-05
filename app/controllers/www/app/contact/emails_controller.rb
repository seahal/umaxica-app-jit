module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        def new
          @service_site_contact = ServiceSiteContact.new
        end

        def create
        end
      end
    end
  end
end
