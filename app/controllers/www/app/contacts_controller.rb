module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare

    def new
      @service_site_contact = ServiceSiteContact.new
      session[:contact_email_address] = nil
      session[:contact_telephone_number] = nil
    end

    def create
      @service_site_contact = ServiceSiteContact.new(sample_params)
      if @service_site_contact.valid? && cloudflare_turnstile_validation["success"]
        id = session[:contact_id] = SecureRandom.uuid_v7
        session[:contact_email_address] = @service_site_contact.email_address
        session[:contact_telephone_number] = @service_site_contact.telephone_number
        redirect_to  www_app_contact_url(id)
      else
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
