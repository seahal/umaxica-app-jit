module Www
  module App
    module Contact
      class EmailsController < ApplicationController
        include ::Contact

        def new
          session[:contact_count] ||= 0
          if [
            !!session[:contact_id],
            !!params[:contact_id],
            session[:contact_id] == params[:contact_id],
            !session[:contact_email_checked],
            !session[:contact_telephone_checked],
            Time.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.now, session[:contact_count] < 10
          ].all?
            # make forms which for email sonzai
            @service_site_contact = ServiceSiteContact.new
          else
            show_error_page
          end
        end

        # new_www_app_contact_email

        def create
          session[:contact_count] ||= 0
          pass_code = params[:service_site_contact][:email_pass_code]
          @service_site_contact = ServiceSiteContact.new(email_pass_code: pass_code)

          b32_private_key = memorize[:contact_otp_private_key]
          hotp_counter = session[:contact_hotp_counter]
          hotp = ROTP::HOTP.new(b32_private_key)
          hotp.verify(pass_code, hotp_counter.to_i)
          hotp_result = hotp.verify(pass_code.to_s, hotp_counter.to_i)
          if @service_site_contact.valid? && [
            session[:contact_id],
            params[:contact_id],
            session[:contact_id] == params[:contact_id],
            memorize[:contact_email_address],
            session[:contact_email_checked] == false,
            session[:contact_telephone_checked] == false,
            ## find out the telephone number
            memorize[:contact_telephone_number], session[:contact_count] < 10,
            # verify pass_code of emails
            hotp_result
            ].all?
            session[:contact_email_checked] = true
            session[:contact_expires_in] = 2.hours.from_now
            session[:contact_count] = 0
            redirect_to new_www_app_contact_telephone_url(params[:contact_id])
          else
            session[:contact_count] += 1
            @service_site_contact.errors.add :base, :invalid, message: t("model.concern.otp:invalid_input") if hotp_result.blank?
            render :new, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
