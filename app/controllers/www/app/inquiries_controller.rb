module Www::App
  class InquiriesController < ApplicationController
    include ::Cloudflare
    include ::Rotp
    include ::Common
    include ::Memorize
    include ::Contact

    def new
      # clear_contact_session
      session[:contact_expires_in] = 2.hours.from_now
      @service_site_contact = ServiceSiteContact.new
    end

    def create
      @service_site_contact = ServiceSiteContact.new(sample_params)
      cfv = cloudflare_turnstile_validation["success"]
      if @service_site_contact.valid? && cfv
        clear_contact_session
        contact_id = SecureRandom.uuid_v4.to_s
        b32_private_key = ROTP::Base32.random
        hotp_counter = 100
        hotp = ROTP::HOTP.new(b32_private_key)
        set_contact_session(contact_id: contact_id,
                            contact_email_checked: false,
                            contact_telephone_checked: false,
                            contact_hotp_counter: hotp_counter,
                            contact_expires_in: 2.hours.from_now,
                            # secure data, so the data is not stored in Redis.
                            contact_otp_private_key: b32_private_key,
                            # secure data, so the data is not stored in Redis.
                            contact_email_address: @service_site_contact.email_address,
                            # secure data, so the data is not stored in Redis.
                            contact_telephone_number: @service_site_contact.telephone_number)
        # FIXME: send email
        Email::App::ContactMailer.with({ email_address: @service_site_contact.email_address, pass_code: hotp.at(hotp_counter) }).create.deliver_now
        # FIXME: send telephone
        redirect_to new_www_app_inquiry_email_url(contact_id)
      else
        @service_site_contact.errors.add :base, :invalid, message: t("model.concern.cloudflare.invalid_input") unless cfv
        clear_contact_session
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
    end

    def show
    end
    #
    #   def edit
    #     show_error_page
    #   end
    #
    #   def update
    #     if [
    #       session[:contact_id] == params[:contact_id],
    #       session[:contact_email_checked] == false,
    #       session[:contact_telephone_checked] == false,
    #       session[:contact_expires_in].to_i > Time.now.to_i
    #     ].all?
    #       # make forms which for email sonzai
    #       @service_site_contact = ServiceSiteContact.new
    #     else
    #       show_error_page
    #     end
    #   end
    #
    private

    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @service_site_contact = ServiceSiteContact.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sample_params
      params.expect(service_site_contact: [ :confirm_policy, :telephone_number, :email_address ])
    end
    # end
  end
end
