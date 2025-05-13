module Www
  module App
    module Contact
      class TelephonesController < ApplicationController
        include ::Contact

        def new
          if [
            !!session[:contact_id],
            !!params[:contact_id],
            session[:contact_id] == params[:contact_id],
            session[:contact_email_checked] == true,
            session[:contact_telephone_checked] == false,
            Time.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.now
          ].all?
            # make forms which for telephoen
            @service_site_contact = ServiceSiteContact.new
          else
            show_error_page
          end
        end

        def create
          p "aaa"
          pass_code = params[:service_site_contact][:telephone_pass_code]
          @service_site_contact = ServiceSiteContact.new(telephone_pass_code: pass_code)
          p "bbb"
          b32_private_key = memorize[:contact_otp_private_key]
          hotp = ROTP::HOTP.new(b32_private_key)
          p "ccc"
          if @service_site_contact.valid? && [
            session[:contact_id],
            params[:contact_id],
            session[:contact_id] == params[:contact_id],
            session[:contact_email_checked] == true,
            session[:contact_telephone_checked] == false,
            # checking hitoku data
            memorize[:contact_email_address],
            ## find out the telephone number
            memorize[:contact_telephone_number],
            # verify pass_code of emal
            hotp.verify(pass_code.to_s, 200)
          ].all?
            session[:contact_telephone_checked] = true
            session[:contact_expires_in] = 2.hours.from_now
            redirect_to edit_www_app_contact_url(params[:contact_id])
          else
            render :new, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
