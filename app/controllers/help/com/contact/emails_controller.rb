module Help
  module Com
    module Contact
      class EmailsController < ApplicationController
        before_action :load_and_validate_contact

        def new
          @contact_email = @contact.com_contact_emails.first
        end

        def create
          @contact_email = @contact.com_contact_emails.first
          hotp_code = params.dig(:com_contact_email, :hotp_code)

          if hotp_code.blank?
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.create.hotp_code_required"))
            render :new, status: :unprocessable_content
            return
          end

          if @contact_email.verify_hotp_code(hotp_code)
            @contact.verify_email!
            redirect_to new_help_com_contact_telephone_url(
                          contact_id: @contact.public_id,
                          **help_email_redirect_options
                        ), notice: I18n.t("help.com.contact.emails.create.success")
          else
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.create.hotp_code_invalid"))
            render :new, status: :unprocessable_content
          end
        end

        private

        def load_and_validate_contact
          contact_id = params[:contact_id]
          if contact_id.blank?
            Rails.logger.error("Contact validation failed: contact_id is blank")
            raise StandardError, "Contact ID is required"
          end

          @contact = ComContact.find_by(public_id: contact_id)
          if @contact.nil?
            Rails.logger.error("Contact validation failed: contact not found for public_id=#{contact_id}")
            raise StandardError, "Contact not found"
          end

          # Validate status must be SET_UP
          unless @contact.contact_status_title == "SET_UP"
            Rails.logger.error("Contact validation failed: invalid status. Expected SET_UP, got #{@contact.contact_status_title} for contact_id=#{contact_id}")
            raise StandardError, "Invalid contact status: expected SET_UP, got #{@contact.contact_status_title}"
          end
        end

        def help_email_redirect_options
          {
            host: help_corporate_host,
            port: request.port,
            protocol: request.protocol.delete_suffix("://")
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
      end
    end
  end
end
