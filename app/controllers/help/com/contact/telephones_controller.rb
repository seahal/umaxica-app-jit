# frozen_string_literal: true

module Help
  module Com
    module Contact
      class TelephonesController < ApplicationController
        before_action :load_and_validate_contact

        def new
          @contact_telephone = ComContactTelephone.find_by(com_contact_id: @contact.id)
        end

        def create
          @contact_telephone = ComContactTelephone.find_by(com_contact_id: @contact.id)

          unless @contact_telephone
            raise StandardError, "Contact telephone not found"
          end

          hotp_code = params.dig(:com_contact_telephone, :hotp_code)

          if hotp_code.blank?
            @contact_telephone.errors.add(:hotp_code, I18n.t("help.com.contact.telephones.create.hotp_code_required"))
            render :new, status: :unprocessable_content
            return
          end

          # Check if attempts left
          if @contact_telephone.verifier_attempts_left <= 0
            @contact_telephone.errors.add(:hotp_code, I18n.t("help.com.contact.telephones.update.max_attempts"))
            render :new, status: :unprocessable_content
            return
          end

          # Check if expired
          if @contact_telephone.verifier_expires_at && Time.current >= @contact_telephone.verifier_expires_at
            @contact_telephone.errors.add(:hotp_code, I18n.t("help.com.contact.telephones.update.expired"))
            render :new, status: :unprocessable_content
            return
          end

          if @contact_telephone.verify_hotp_code(hotp_code)
            # Update contact status to CHECKED_TELEPHONE_NUMBER
            @contact.verify_phone!

            redirect_url = edit_help_com_contact_url(
              @contact,
              **preserved_locale_query_params,
              **help_telephone_redirect_options,
            )

            redirect_to redirect_url, notice: I18n.t("help.com.contact.telephones.update.success")
          else
            # Reload to get updated attempts_left, but save it before reload clears errors
            @contact_telephone.reload
            attempts_left = @contact_telephone.verifier_attempts_left

            if attempts_left > 0
              @contact_telephone.errors.add(:hotp_code,
                                            I18n.t("help.com.contact.telephones.update.invalid_code",
                                                   attempts_left: attempts_left,),)
            else
              @contact_telephone.errors.add(:hotp_code, I18n.t("help.com.contact.telephones.update.max_attempts"))
            end
            render :new, status: :unprocessable_content
          end
        end

        private

        def load_and_validate_contact
          contact_id = params[:contact_id]

          if contact_id.blank?
            raise StandardError, "Contact ID is required"
          end

          @contact = ComContact.find_by(public_id: contact_id)

          if @contact.nil?
            raise StandardError, "Contact not found"
          end

          unless @contact.status_id == "CHECKED_EMAIL_ADDRESS"
            raise StandardError,
                  "Invalid contact status: expected CHECKED_EMAIL_ADDRESS, got #{@contact.status_id}"
          end
        end

        def help_telephone_redirect_options
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
