# typed: false
# frozen_string_literal: true

module Core
  module Com
    module Contact
      class TelephonesController < Core::Com::ApplicationController
        include ::RateLimit

        before_action :load_and_validate_contact

        def new
          @contact_telephone = ComContactTelephone.find_by(com_contact_id: @contact.id)
        end

        def create
          @contact_telephone = ComContactTelephone.find_by(com_contact_id: @contact.id)
          return render_missing_contact_telephone unless @contact_telephone

          hotp_code = params.dig(:com_contact_telephone, :hotp_code)

          if hotp_code.blank?
            @contact_telephone.errors.add(
              :hotp_code,
              I18n.t("help.com.contact.telephones.create.hotp_code_required"),
            )
            render :new, status: :unprocessable_content
            return
          end

          # Check if attempts left
          if @contact_telephone.verifier_attempts_left <= 0
            @contact_telephone.errors.add(
              :hotp_code,
              I18n.t("help.com.contact.telephones.update.max_attempts"),
            )
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
            return render_invalid_contact_state unless @contact.verify_phone!

            redirect_url = core_com_contact_url(
              @contact,
              **preserved_locale_query_params,
              **core_corporate_redirect_options,
            )

            redirect_to(redirect_url, notice: I18n.t("help.com.contact.telephones.update.success"))
          else
            # Reload to get updated attempts_left, but save it before reload clears errors
            @contact_telephone.reload
            attempts_left = @contact_telephone.verifier_attempts_left

            if attempts_left > 0
              @contact_telephone.errors.add(
                :hotp_code,
                I18n.t(
                  "help.com.contact.telephones.update.invalid_code",
                  attempts_left: attempts_left,
                ),
              )
            else
              @contact_telephone.errors.add(
                :hotp_code,
                I18n.t("help.com.contact.telephones.update.max_attempts"),
              )
            end
            render :new, status: :unprocessable_content
          end
        end

        private

        def load_and_validate_contact
          contact_id = params[:contact_id]
          return render_missing_contact_id if contact_id.blank?

          @contact = ComContact.find_by(public_id: contact_id)
          return render_missing_contact unless @contact

          return if @contact.status_id == ComContactStatus::CHECKED_EMAIL_ADDRESS

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

        def render_missing_contact_telephone
          render plain: "Contact telephone not found", status: :not_found
        end

        def render_invalid_contact_state
          render plain: "Invalid contact status", status: :unprocessable_content
        end
      end
    end
  end
end
