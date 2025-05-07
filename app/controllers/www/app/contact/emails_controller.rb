module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        include ::Contact

        def new
          # check sesion
          ## checking valid hotp
          ## checking valid step
          ## checking not email validation
          ## checking not telephone validation
          ## checking time
          # if [ true ].all?
          #   render template: "www/app/contacts/error", status: :unprocessable_entity
          # end
          # make forms which for email sonzai
          @service_site_contact = ServiceSiteContact.new
        end
        #new_www_app_contact_email

        def create
        end
      end
    end
  end
end
