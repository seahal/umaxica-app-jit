module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        include ::Contact

        def new
          if [
            !!session[:contact_id],
            !!params[:contact_id],
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
          pass_code = params[:service_site_contact][:email_pass_code]
          @service_site_contact = ServiceSiteContact.new(email_pass_code: pass_code)

          p pass_code
          p b32_private_key = memorize[:contact_otp_private_key]
          p hotp_counter = session[:contact_hotp_counter]
          p hotp = ROTP::HOTP.new(b32_private_key)
          p hotp.verify(pass_code, hotp_counter.to_i)
          #
          p memorize[:contact_email_address]
          p memorize[:contact_telephone_number]
          p           !!session[:contact_id],
                      !!params[:contact_id],
                      session[:contact_id] == params[:contact_id],
                      !!memorize[:contact_email_address]

            if @service_site_contact.valid? && [
            !!session[:contact_id],
            !!params[:contact_id],
            session[:contact_id] == params[:contact_id],
            !!memorize[:contact_email_address],
            ## find out the telephone number
            !!memorize[:contact_telephone_number],
            # verify pass_code of emal
            !!hotp.verify(pass_code, hotp_counter)
          ].all?
            @service_site_contact.step = :telephone
            session[:contact_email_checked] = true
            redirect_to new_www_app_contact_telephone_url(params[:contact_id])
          else
            render :new, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
