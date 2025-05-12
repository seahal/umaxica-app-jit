module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare
    include ::Contact
    include ::Rotp
    include ::Common

    def new
      clear_contact_session
      session[:contact_expires_in] = 2.hours.from_now
      @service_site_contact = ServiceSiteContact.new
    end

    def create
      @service_site_contact = ServiceSiteContact.new(create_params)
      cfv = cloudflare_turnstile_validation["success"]
      if @service_site_contact.valid? && cfv
        clear_contact_session
        contact_id = SecureRandom.uuid_v4.to_s
        b32_private_key = ROTP::Base32.random
        hotp_counter = 100 # FIXME: remove!
        hotp = ROTP::HOTP.new(b32_private_key)
        set_contact_session(contact_id: contact_id,
                            contact_email_checked: false,
                            contact_telephone_checked: false,
                            contact_hotp_counter: hotp_counter, # FIXME: remove!
                            contact_expires_in: 2.hours.from_now,
                            # secure data, so the data is not stored in Redis.
                            contact_otp_private_key: b32_private_key,
                            # secure data, so the data is not stored in Redis.
                            contact_email_address: @service_site_contact.email_address,
                            # secure data, so the data is not stored in Redis.
                            contact_telephone_number: @service_site_contact.telephone_number)

        # send email which contains a pass code
        contact_email_pass_code = hotp.at(100)
        session[:contact_email_pass_code] = contact_email_pass_code if Rails.env.test?
        send_otp_code_using_email(pass_code: contact_email_pass_code, email_address: @service_site_contact.email_address) unless Rails.env.test?
        # send email which contains a pass code
        contact_telephone_pass_code = hotp.at(200)
        session[:contact_telephone_pass_code] = contact_telephone_pass_code if Rails.env.test?
        send_otp_code_using_sms(pass_code: contact_telephone_pass_code, telephone_number: @service_site_contact.telephone_number) unless Rails.env.test?
        # move to another controller
        redirect_to new_www_app_contact_email_url(contact_id)
      else
        @service_site_contact.errors.add :base, :invalid, message: t("model.concern.cloudflare.invalid_input") unless cfv
        clear_contact_session
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      if [
        !!params[:id],
        !!session[:contact_id],
        session[:contact_id] == params[:id],
        session[:contact_email_checked],
        session[:contact_telephone_checked],
        Time.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.now
      ].all?
        # make forms which for email sonzai
        @service_site_contact = ServiceSiteContact.new
      else
        show_error_page
      end
    end

    def update
      @service_site_contact = ServiceSiteContact.new(update_params)
      if @service_site_contact.valid? && [
        !!params[:id],
        !!session[:contact_id],
        session[:contact_id] == params[:id],
        session[:contact_email_checked] == true,
        session[:contact_telephone_checked] == true,
        Time.parse(session[:contact_expires_in] || "1970-01-01T00:00:00") > Time.now
      ].all?
        @service_site_contact.id = gen_original_uuid
        @service_site_contact.email_address = memorize[:contact_email_address]
        @service_site_contact.telephone_number = memorize[:contact_telephone_number]
        @service_site_contact.id = gen_original_uuid
        @service_site_contact.save!
        session[:contact_email_checked] = false
        # make forms which for email sonzai @service_site_contact
        redirect_to www_app_contact_url(@service_site_contact.id)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      if [
        !!params[:id],
        !!session[:contact_id],
        session[:contact_id] != params[:id],
        session[:contact_email_checked] == false, # NOTE: you would strange to see, but false is Right for here.
        session[:contact_telephone_checked] == true
      ].all?
        clear_contact_session
      else
        show_error_page
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @service_site_contact = ServiceSiteContact.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def create_params
      params.expect(service_site_contact: [ :confirm_policy, :telephone_number, :email_address ])
    end

    # Only allow a list of trusted parameters through.
    def update_params
      params.expect(service_site_contact: [ :title, :description ])
    end
  end
end
