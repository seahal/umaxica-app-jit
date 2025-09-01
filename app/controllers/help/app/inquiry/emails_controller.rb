module Www
  module App
    module Inquiry
      # EmailsController handles the email contact process for inquiries.
      # It includes methods to create a new email contact and validate the pass code.
      class EmailsController < ApplicationController
        include ::Inquiry
        include ::Memorize

        MAX_CONTACT_COUNT = 10

        before_action :ensure_contact_count, only: :create

        def new
        end

        def create
        end

        private

        def allow_new_contact_email?
          [
            params[:contact_id].present?,
            get_contact_cookie(:id),
            !get_contact_cookie(:contact_email_checked),
            !get_contact_cookie(:contact_telephone_checked),
            get_contact_cookie(:id) == params[:contact_id],
            session_expires_in_future?,
            get_contact_cookie(:contact_count).to_i < MAX_CONTACT_COUNT
          ].all?
        end

        def allow_create_contact_email?
          [
            session[:contact_id],
            params[:contact_id],
            session[:contact_id] == params[:contact_id],
            memorize[:contact_email_address],
            session[:contact_email_checked] == false,
            session[:contact_telephone_checked] == false,
            memorize[:contact_telephone_number],
            session[:contact_count].to_i < MAX_CONTACT_COUNT
          ].all? && @service_site_contact.valid?
        end

        def valid_hotp?(pass_code)
          b32_private_key = memorize[:contact_otp_private_key]
          hotp_counter = session[:contact_hotp_counter].to_i
          hotp = ROTP::HOTP.new(b32_private_key)
          hotp.verify(pass_code.to_s, hotp_counter)
        end

        def session_expires_in_future?
          Time.zone.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.current
        end

        def set_contact_email_checked
          session[:contact_email_checked] = true
          session[:contact_expires_in] = 2.hours.from_now.to_s
        end

        def init_contact_count_cookie
          set_contact_cookie(:contact_count, get_contact_cookie(:contact_count) || 0)
        end

        def increment_contact_count
          session[:contact_count] = session[:contact_count].to_i + 1
        end

        def reset_contact_count
          session[:contact_count] = 0
        end

        def ensure_contact_count
          session[:contact_count] ||= 0
        end
      end
    end
  end
end
