# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module In
      class SecretsController < ApplicationController
        include ::CloudflareTurnstile
        include SessionLimitGate

        class SecretLoginForm
          include ActiveModel::Model

          attr_accessor :identifier, :secret_value

          validates :identifier, presence: true
          validate :identifier_matches_staff_public_id_format
          validates :secret_value, presence: true

          def self.model_name
            ActiveModel::Name.new(self, nil, "secret_login_form")
          end

          private

          def identifier_matches_staff_public_id_format
            normalized_identifier = Staff.normalize_public_id(identifier)
            return if normalized_identifier.blank?
            return if Staff::PUBLIC_ID_FORMAT.match?(normalized_identifier)

            errors.add(:identifier, :invalid)
          end
        end

        SecretVerificationResult = Struct.new(:secret, :reason, keyword_init: true)

        before_action :reject_logged_in_session

        def new
          @secret_form = SecretLoginForm.new
        end

        def create
          @secret_form = SecretLoginForm.new(secret_params)
          unless @secret_form.valid?
            return render_failed_login(:form_invalid)
          end

          unless cloudflare_turnstile_validation["success"]
            return render_failed_login(:turnstile_failed)
          end

          staff = find_staff_by_public_id(@secret_form.identifier)
          return render_session_limit_hard_reject if session_limit_hard_reject_for?(staff)

          verification = verify_secret_for_sign_in(staff: staff, raw_secret: @secret_form.secret_value)

          if staff && verification.secret
            process_standard_login(staff)
          else
            render_failed_login(verification.reason || :identifier_not_found)
          end
        rescue StandardError => e
          Rails.event.error(
            "sign.org.authentication.secret.error",
            error_class: e.class.name,
            message: e.message,
            ip: request.remote_ip,
            exception: e,
          )
          render_failed_login(:internal_error)
        end

        private

        def find_staff_by_public_id(identifier)
          normalized_identifier = Staff.normalize_public_id(identifier)
          return if normalized_identifier.blank?

          Staff.find_by(public_id: normalized_identifier, status_id: StaffStatus::ACTIVE)
        end

        def verify_secret_for_sign_in(staff:, raw_secret:)
          return SecretVerificationResult.new(reason: :identifier_not_found) unless staff

          secret = staff.staff_secrets
            .where(
              staff_identity_secret_status_id: StaffSecretStatus::ACTIVE,
              staff_secret_kind_id: StaffSecretKind::LOGIN,
            )
            .order(created_at: :desc)
            .first

          return SecretVerificationResult.new(reason: :secret_not_found) unless secret
          unless secret.verify_and_consume!(raw_secret.to_s)
            return SecretVerificationResult.new(reason: :secret_mismatch)
          end

          SecretVerificationResult.new(secret: secret, reason: :success)
        end

        def process_standard_login(staff)
          result = log_in(staff, record_login_audit: true, require_totp_check: false)

          if result[:status] == :session_limit_hard_reject
            render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
          elsif result[:restricted]
            redirect_to sign_org_in_session_path, notice: I18n.t("sign.org.in.session.restricted_notice")
          else
            issue_checkpoint!
            redirect_to sign_org_in_checkpoint_path(rd: params[:rd], ri: params[:ri]),
                        notice: t("sign.org.authentication.secret.create.success")
          end
        end

        def render_failed_login(reason)
          @secret_form ||= SecretLoginForm.new
          @secret_form.errors.add(:base, invalid_secret_message)

          Rails.event.info(
            "sign.org.authentication.secret.failed",
            reason: reason,
            identifier_present: @secret_form.identifier.present?,
            ip: request.remote_ip,
            errors: @secret_form.errors.full_messages,
          )

          render :new, status: :unprocessable_content, formats: :html
        end

        def invalid_secret_message
          t("sign.org.authentication.secret.create.invalid")
        end

        def secret_params
          params.fetch(:secret_login_form, {}).permit(:identifier, :secret_value)
        end
      end
    end
  end
end
