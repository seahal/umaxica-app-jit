module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare
    include ::Contact

    def new
      clear_session
      @service_site_contact = ServiceSiteContact.new(step: :introduction)
    end

    def create
      @service_site_contact = ServiceSiteContact.new(sample_params)
      cfv = cloudflare_turnstile_validation["success"]
      if @service_site_contact.valid? && cfv
        clear_session
        b32_private_key = ROTP::Base32.random_base32
        hotp = ROTP::HOTP.new(b32_private_key)
        counter = SecureRandom.random_number(2 ** 100)
        session[:contact_id] = id = hotp.at(counter)
        session[:contact_email_address] = @service_site_contact.email_address
        session[:contact_telephone_number] = @service_site_contact.telephone_number
        session[:contact_otp_private_key] = b32_private_key
        session[:contact_expires_in] = 2.hours.from_now
        session[:contact_email_checked] = false
        session[:contact_telephone_checked] = false
        redirect_to new_www_app_contact_email_url(id)
      else
        @service_site_contact.errors.add :base, :invalid, message: t("model.concern.cloudflare.invalid_input") unless cfv
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

    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @service_site_contact = ServiceSiteContact.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sample_params
      params.expect(service_site_contact: [ :confirm_policy, :telephone_number, :email_address ])
    end
  end
end
