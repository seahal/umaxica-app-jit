module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        include ::Contact

        def new
          # check sesion
          p 'a' * 100
          p check_all_contact_session_not_nil?
          p params[:contact_id], session[:contact_otp_counter].to_i, session[:contact_otp_private_key], session[:contact_hotp]
          p ROTP::HOTP.new(session[:contact_otp_private_key]).verify(params[:contact_id].to_s, session[:contact_hotp_counter].to_i)
          # p session[:contact_hotp].verify(params[:contact_id], session[:contact_otp_counter].to_i)
          if check_all_contact_session_not_nil? && [
            # checking valid step
            !ROTP::HOTP.new(session[:contact_otp_private_key]).verify(params[:contact_id], session[:contact_hotp_counter].to_i).nil?,
            ## checking not email validation
            !session[:contact_email_checked],
            ## checking not telephone validation
            !session[:contact_telephone_checked],
            ## checking time
            session[:contact_expires_in] < Time.now
          ].all?{ !it.nil? }
            show_error_page
          else
            # make forms which for email sonzai
            @service_site_contact = ServiceSiteContact.new
          end
        end
        # new_www_app_contact_email

        def create
          @service_site_contact = ServiceSiteContact.new(email_pass_code: params[:service_site_contact][:email_pass_code])
          if @service_site_contact.valid? && @service_site_contact.step=:email
            @service_site_contact.step= :telephone
            raise
          else
            render :new, status: :unprocessable_entity
          end
        end

        private
        def show_error_page
            clear_contact_session
            render template: "www/app/contacts/error", status: :unprocessable_entity and return
        end
      end
    end
  end
end
