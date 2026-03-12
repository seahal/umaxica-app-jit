# typed: false
# frozen_string_literal: true

module Core
  module Com
    module Contact
      class EmailsController < Core::Com::ApplicationController
        include ::RateLimit

        before_action :load_and_validate_contact

        def new
          @contact_email = ComContactEmail.find_by(com_contact_id: @contact.id)
        end

        def create
          @contact_email = ComContactEmail.find_by(com_contact_id: @contact.id)
          return render_missing_contact_email unless @contact_email

          hotp_code = params.dig(:com_contact_email, :hotp_code)
          return handle_missing_code if hotp_code.blank?
          return if check_limits!

          if @contact_email.verify_hotp_code(hotp_code)
            process_verification
          else
            handle_invalid_code
          end
        end

        def handle_missing_code
          @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.create.hotp_code_required"))
          render :new, status: :unprocessable_content
        end

        def check_limits!
          if @contact_email.verifier_attempts_left <= 0
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.max_attempts"))
            render :new, status: :unprocessable_content
            return true
          end

          if @contact_email.verifier_expires_at && Time.current >= @contact_email.verifier_expires_at
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.expired"))
            render :new, status: :unprocessable_content
            return true
          end

          false
        end

        def process_verification
          @contact.update!(status_id: ComContactStatus::CHECKED_EMAIL_ADDRESS)

          redirect_url = new_core_com_contact_telephone_url(
            @contact,
            **preserved_locale_query_params,
            **core_corporate_redirect_options,
          )

          generate_and_send_telephone_token

          redirect_to redirect_url, notice: I18n.t("help.com.contact.emails.update.success")
        end

        def generate_and_send_telephone_token
          @contact_telephone = @contact.com_contact_telephone
          return unless @contact_telephone

          ActiveRecord::Base.transaction do
            telephone_token = @contact_telephone.generate_hotp!
            AwsSmsService.new.send_message(
              to: @contact_telephone.telephone_number,
              message: "PassCode => #{telephone_token}",
            )
          end
        end

        def handle_invalid_code
          @contact_email.reload
          attempts_left = @contact_email.verifier_attempts_left

          if attempts_left > 0
            @contact_email.errors.add(
              :hotp_code,
              I18n.t("help.com.contact.emails.update.invalid_code", attempts_left: attempts_left),
            )
          else
            @contact_email.errors.add(:hotp_code, I18n.t("help.com.contact.emails.update.max_attempts"))
          end
          render :new, status: :unprocessable_content
        end

        private

        def load_and_validate_contact
          contact_id = params[:contact_id]
          return render_missing_contact_id if contact_id.blank?

          @contact = ComContact.find_by(public_id: contact_id)
          return render_missing_contact unless @contact
          return if @contact.status_id == ComContactStatus::SET_UP

          render_invalid_contact_state
        end

        def core_corporate_redirect_options
          {
            host: core_corporate_host,
            port: request.port,
            protocol: request.protocol.delete_suffix("://"),
          }.compact
        end

        def core_corporate_host
          env_url = ENV["CORE_CORPORATE_URL"].presence
          return request.host unless env_url

          begin
            uri = URI.parse(env_url.start_with?("http") ? env_url : "http://#{env_url}")
            uri.host || env_url.split(":").first
          rescue URI::InvalidURIError
            env_url.split(":").first
          end
        end

        def preserved_locale_query_params
          request.query_parameters.slice("ct", "lx", "ri", "tz").compact
        end

        def render_missing_contact_id
          render plain: "Contact ID is required", status: :bad_request
        end

        def render_missing_contact
          render plain: "Contact not found", status: :not_found
        end

        def render_missing_contact_email
          render plain: "Contact email not found", status: :not_found
        end

        def render_invalid_contact_state
          render plain: "Invalid contact status", status: :unprocessable_content
        end
      end
    end
  end
end
