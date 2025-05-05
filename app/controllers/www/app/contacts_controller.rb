module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare

    def new
      @service_site_contact = ServiceSiteContact.new
      clear_session
    end

    def create
      @service_site_contact = ServiceSiteContact.new(sample_params)
      if @service_site_contact.valid? && cloudflare_turnstile_validation["success"]
        clear_session
        session[:contact_id] = id = SecureRandom.uuid_v7
        session[:contact_email_address] = @service_site_contact.email_address
        session[:contact_telephone_number] = @service_site_contact.telephone_number
        session[:contact_otp_private_key] = ROTP::Base32.random_base32
        session[:contact_expires_in] = 2.hours.from_now
        session[:contact_email_checked] = false
        session[:contact_telephone_checked] = false
        redirect_to new_www_app_contact_email_url(session[:contact_id])
      else
        clear_session
        render :new, status: :unprocessable_entity
      end
    end

    def update
    end

    def edit
    end

    def show
    end

    private

    def clear_session
      session[:contact_id] = nil
      session[:contact_email_address] = nil
      session[:contact_telephone_number] = nil
      session[:contact_email_checked] = nil
      session[:contact_telephone_checked] = nil
      session[:contact_otp_private_key] = nil
      session[:contact_expires_in] = nil
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @service_site_contact = ServiceSiteContact.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sample_params
      params.expect(service_site_contact: [:confirm_policy, :telephone_number, :email_address])
    end
  end
end
