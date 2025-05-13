module Www
  module App
    module Contact
      class TelephonesController < ApplicationController
        include ::Contact

        def new
          raise
        end

        def new
          if [
            !!session[:contact_id],
            !!params[:contact_id],
            session[:contact_id] == params[:contact_id],
            session[:contact_email_checked] == false,
            session[:contact_telephone_checked] == false,
            session[:contact_expires_in].to_i > Time.now.to_i
          ].all?
            # make forms which for telephoen
            @service_site_contact = ServiceSiteContact.new
          else
            show_error_page
          end
        end

        def create
        end
      end
    end
  end
end
