module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        include ::Contact

        def new
          if [
            session[:contact_id],
            params[:contact_id],
            session[:contact_id] == params[:contact_id],
            !session[:contact_email_checked],
            !session[:contact_telephone_checked],
            Time.parse(session[:contact_expires_in] || '1970-01-01T00:00:00') > Time.now
          ].all?
            # make forms which for email sonzai
            @service_site_contact = ServiceSiteContact.new
          else
            show_error_page
          end
        end

        # new_www_app_contact_email

        def create
          @service_site_contact = ServiceSiteContact.new(email_pass_code: params[:service_site_contact][:email_pass_code])
          if @service_site_contact.valid? && [
            !!session[:contact_id],
            !!params[:contact_id],
            # checking input value
            @service_site_contact.step == :email,
            # checking valid Redis value
            ## find out email address
            memorize[:contact_email_address],
            ## find out the telephone number
            memorize[:contact_telephone_number]].all?
            @service_site_contact.step = :telephone
            redirect_to new_www_app_contact_telephone_url(contact_id)
          else
            render :new, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
