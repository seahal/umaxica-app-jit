module Www
  module App
    module Contact
      class TelephonesController < ApplicationController
        include ::Contact

        def new
          session[:contact_count] ||= 0
          if [
            !!session[:contact_id],
            !!params[:contact_id],
            session[:contact_id] == params[:contact_id],
            session[:contact_email_checked] == true,
            session[:contact_telephone_checked] == false,
            Time.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.now,
            session[:contact_count] < 10
          ].all?
            # make forms which for telephoen
            @service_site_contact = ServiceSiteContact.new
          else
            show_error_page
          end
        end

        def create
          session[:contact_count] ||= 0
          pass_code = params[:service_site_contact][:telephone_pass_code]
          @service_site_contact = ServiceSiteContact.new(telephone_pass_code: pass_code)
          b32_private_key = memorize[:contact_otp_private_key]
          hotp = ROTP::HOTP.new(b32_private_key)
          hotp_result = hotp.verify(pass_code.to_s, 200)
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
            hotp_result,
            session[:contact_count] < 10
          ].all?
            session[:contact_telephone_checked] = true
            session[:contact_expires_in] = 2.hours.from_now
            session[:contact_count] = 0
            redirect_to edit_www_app_contact_url(params[:contact_id])
          else
            @service_site_contact.errors.add :base, :invalid, message: t("model.concern.otp.invalid_input") if hotp_result.blank?
            render :new, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
