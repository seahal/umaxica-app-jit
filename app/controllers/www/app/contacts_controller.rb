module Www::App
  class ContactsController < ApplicationController
    include ::Cloudflare
    include ::Contact
    include ::Rotp
    include ::Common

    before_action :initialize_contact_cookies, only: [ :create, :edit ]
    before_action :validate_session_for_edit, only: [ :edit ]
    before_action :validate_session_for_update, only: [ :update ]
    before_action :validate_session_for_show, only: [ :show ]

    def new
      clear_contact_session
      session[:contact_count] ||= 0
      session[:contact_expires_in] = 2.hours.from_now
      @service_site_contact = ServiceSiteContact.new
    end

    def create
      @service_site_contact = ServiceSiteContact.new(get_contact_cookie(:id))
      if @service_site_contact.valid? && cloudflare_valid?
        process_contact_creation
        redirect_to new_www_app_contact_email_url(get_contact_cookie(:id))
      else
        handle_invalid_create
      end
    end

    def edit
      @service_site_contact = ServiceSiteContact.new
    end

    def update
      @service_site_contact = ServiceSiteContact.new(update_params)

      if @service_site_contact.valid?
        save_contact_with_verified_data
        redirect_to www_app_contact_url(@service_site_contact.id)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      if valid_show_state?
        session[:contact_count] = 0
        clear_contact_session
      else
        show_error_page
      end
    end

    private
      # Only allow a list of trusted parameters through.
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
