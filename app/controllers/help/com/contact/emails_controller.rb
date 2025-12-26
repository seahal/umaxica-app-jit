# frozen_string_literal: true

module Help
  module Com
    module Contact
      class EmailsController < ApplicationController
        rescue_from Help::ContactError, with: :handle_contact_error
        before_action :load_and_validate_contact

        def new
          @contact_email = ComContactEmail.find_by(com_contact_id: @contact.id)
        end

        def create
          @contact_email = ComContactEmail.find_by(com_contact_id: @contact.id)

          unless @contact_email
            raise StandardError, "Contact email not found"
          end

          hotp_code = params.dig(:com_contact_email, :hotp_code)

          if hotp_code.blank?
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.create.hotp_code_required"))
            render :new, status: :unprocessable_content
            return
          end

          # Check if attempts left
          if @contact_email.verifier_attempts_left <= 0
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.max_attempts"))
            render :new, status: :unprocessable_content
            return
          end

          # Check if expired
          if @contact_email.verifier_expires_at && Time.current >= @contact_email.verifier_expires_at
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.expired"))
            render :new, status: :unprocessable_content
            return
          end

          if @contact_email.verify_hotp_code(hotp_code)
            # Update contact status to CHECKED_EMAIL_ADDRESS
            @contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")

            redirect_url = new_help_com_contact_telephone_url(
              @contact,
              **preserved_locale_query_params,
              **help_email_redirect_options,
            )

            # Generate HOTP for telephone verification and send via email
            @contact_telephone = @contact.com_contact_telephone

            if @contact_telephone
              ActiveRecord::Base.transaction do
                # Generate HOTP code
                telephone_token = @contact_telephone.generate_hotp!

                AwsSmsService.new.send_message(to: @contact_telephone.telephone_number,
                                               message: "PassCode => #{telephone_token}",)
              end
            end

            redirect_to redirect_url, notice: I18n.t("help.com.contact.emails.update.success")
          else
            # Reload to get updated attempts_left, but save it before reload clears errors
            @contact_email.reload
            attempts_left = @contact_email.verifier_attempts_left

            if attempts_left > 0
              @contact_email.errors.add(:hotp_code,
                                        I18n.t("help.com.contact.emails.update.invalid_code",
                                               attempts_left: attempts_left,),)
            else
              @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.max_attempts"))
            end
            render :new, status: :unprocessable_content
          end
        end

        private

        def load_and_validate_contact
          contact_id = params[:contact_id]

          raise Help::ContactIdRequiredError if contact_id.blank?

          @contact = ComContact.find_by(public_id: contact_id)

          raise Help::ContactNotFoundError if @contact.nil?

          raise Help::InvalidContactStatusError.new(@contact.status_id) unless @contact.status_id == "SET_UP"
        end

        def handle_contact_error(error)
          render plain: error.message, status: error.status_code
        end

        def help_email_redirect_options
          {
            host: help_corporate_host,
            port: request.port,
            protocol: request.protocol.delete_suffix("://"),
          }.compact
        end

        def help_corporate_host
          host_value = ENV["HELP_CORPORATE_URL"].presence || request.host
          return request.host if host_value.blank?

          begin
            uri = URI.parse(host_value.start_with?("http") ? host_value : "http://#{host_value}")
            uri.host || host_value.split(":").first
          rescue URI::InvalidURIError
            host_value.split(":").first
          end
        end

        def preserved_locale_query_params
          request.query_parameters.slice("ct", "lx", "ri", "tz").compact
        end
      end
    end
  end
end
