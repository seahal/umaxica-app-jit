# frozen_string_literal: true

require "json"

module Sign
  module App
    class ReauthController < ApplicationController
      include Common::Otp
      include Sign::Webauthn

      auth_required!
      REAUTH_EMAIL_OTP_SESSION_KEY = :reauth_email_otp
      before_action :authenticate_user!

      before_action :set_actor_token
      before_action :set_reauth_session, only: %i(show edit update destroy)
      before_action :ensure_pending_and_not_expired!, only: %i(edit update destroy)

      def index
        @reauth_sessions =
          ReauthSession
            .for_actor(@actor_token)
            .recent_first
            .limit(50)
      end

      def show
      end

      def new
        @reauth_session = ReauthSession.new(
          scope: params[:scope].to_s,
          return_to: params[:return_to].to_s,
        )
      end

      def edit
        prepare_passkey_challenge! if @reauth_session.method == "passkey"
      end

      def create
        attrs = create_params
        @reauth_session =
          ReauthSession.new(
            actor: @actor_token,
            scope: attrs[:scope].to_s,
            return_to: normalize_encoded_return_to!(attrs[:return_to].to_s),
            method: attrs[:method].to_s,
            status: "PENDING",
            expires_at: 10.minutes.from_now,
          )

        if @reauth_session.save
          prepare_method_side_effects!(@reauth_session)
          redirect_to sign_app_verification_path(ri: params[:ri])
        else
          render :new, status: :unprocessable_content
        end
      rescue ArgumentError
        @reauth_session ||= ReauthSession.new
        @reauth_session.errors.add(:return_to, :invalid)
        render :new, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid => e
        @reauth_session = e.record
        render :new, status: :unprocessable_content
      end

      def update
        if verify!
          verify_success!
        else
          @reauth_session.update!(attempt_count: @reauth_session.attempt_count + 1)
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @reauth_session.update!(status: "CANCELLED")
        redirect_to sign_app_verification_path(
          scope: @reauth_session.scope,
          return_to: @reauth_session.return_to,
          ri: params[:ri],
        ), status: :see_other
      end

      private

      def set_actor_token
        @actor_token = token_class.find_by!(public_id: current_session_public_id)
      end

      def set_reauth_session
        @reauth_session = ReauthSession.for_actor(@actor_token).find(params[:id])
      end

      def ensure_pending_and_not_expired!
        return head(:gone) unless @reauth_session.status == "PENDING"

        head(:gone) if @reauth_session.expires_at <= Time.current
      end

      def create_params
        params.expect(reauth_session: %i(scope return_to method))
      rescue ActionController::ParameterMissing
        {}
      end

      def update_params
        params.fetch(:reauth_session, {}).permit(:code, :challenge_id, :credential_json)
      end

      def normalize_encoded_return_to!(encoded)
        decoded = Base64.urlsafe_decode64(encoded)
        safe = safe_internal_path(decoded)
        raise ArgumentError, "unsafe return_to" if safe.blank?

        Base64.urlsafe_encode64(safe)
      rescue ArgumentError
        raise
      end

      def prepare_method_side_effects!(reauth_session)
        case reauth_session.method
        when "email_otp"
          send_email_otp!(reauth_session)
        end
      end

      def send_email_otp!(reauth_session)
        user_email =
          current_user.user_emails.where(
            user_email_status_id: UserEmailStatus::VERIFIED,
          ).order(created_at: :desc).first
        unless user_email
          reauth_session.update!(status: "CANCELLED")
          reauth_session.errors.add(:base, "メールアドレスが未確認です")
          raise ActiveRecord::RecordInvalid, reauth_session
        end

        secret, counter, pass_code = generate_hotp_code
        session[REAUTH_EMAIL_OTP_SESSION_KEY] ||= {}
        session[REAUTH_EMAIL_OTP_SESSION_KEY][reauth_session.id] = {
          "secret" => secret,
          "counter" => counter,
          "expires_at" => reauth_session.expires_at.to_i,
        }

        Email::App::RegistrationMailer.with(
          hotp_token: pass_code,
          email_address: user_email.address,
          public_id: current_user.public_id,
          verification_token: nil,
        ).create.deliver_later
      end

      def verify!
        case @reauth_session.method
        when "totp"
          verify_totp!
        when "email_otp"
          verify_email_otp!
        when "passkey"
          verify_passkey!
        else
          @reauth_session.errors.add(:base, "無効な認証方法です")
          false
        end
      end

      def verify_totp!
        code = update_params[:code].to_s
        unless code.match?(/\A\d{6}\z/)
          @reauth_session.errors.add(:base, "確認コードが不正です")
          return false
        end

        totps =
          current_user.user_one_time_passwords
            .where(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
            .order(created_at: :desc)

        totps.any? do |totp|
          ROTP::TOTP.new(totp.private_key).verify(code)
        end
      end

      def verify_email_otp!
        code = update_params[:code].to_s
        unless code.match?(/\A\d{6}\z/)
          @reauth_session.errors.add(:base, "確認コードが不正です")
          return false
        end

        data = session.dig(REAUTH_EMAIL_OTP_SESSION_KEY, @reauth_session.id)
        unless data
          @reauth_session.errors.add(:base, "確認コードの再送信が必要です")
          return false
        end

        if Time.current.to_i > data["expires_at"].to_i
          @reauth_session.errors.add(:base, "確認コードの有効期限が切れました")
          return false
        end

        ok = verify_hotp_code(secret: data["secret"], counter: data["counter"], pass_code: code)
        session[REAUTH_EMAIL_OTP_SESSION_KEY].delete(@reauth_session.id) if ok
        ok
      end

      def prepare_passkey_challenge!
        allow_credentials = current_user.user_passkeys.map { |pk| { id: pk.webauthn_id } }
        if allow_credentials.empty?
          @reauth_session.errors.add(:base, "パスキーが登録されていません")
          return
        end

        @passkey_challenge_id, @passkey_request_options =
          create_authentication_challenge(allow_credentials: allow_credentials)
      end

      def verify_passkey!
        challenge_id = update_params[:challenge_id].to_s
        credential_json = update_params[:credential_json].to_s
        if challenge_id.blank? || credential_json.blank?
          @reauth_session.errors.add(:base, "パスキー認証データが不足しています")
          return false
        end

        credential_hash = JSON.parse(credential_json)

        with_challenge(challenge_id, purpose: :authentication) do |challenge|
          credential = WebAuthn::Credential.from_get(credential_hash, relying_party: webauthn_relying_party)
          passkey = UserPasskey.find_by(webauthn_id: credential.id)
          unless passkey && passkey.user_id == current_user.id
            @reauth_session.errors.add(:base, I18n.t("errors.webauthn.credential_not_found"))
            next false
          end

          credential.verify(
            challenge,
            public_key: passkey.public_key,
            sign_count: passkey.sign_count,
          )
          passkey.update!(sign_count: credential.sign_count)
          true
        end
      rescue Sign::Webauthn::ChallengeNotFoundError,
             Sign::Webauthn::ChallengeExpiredError,
             Sign::Webauthn::ChallengePurposeMismatchError
        @reauth_session.errors.add(:base, I18n.t("errors.webauthn.challenge_invalid"))
        false
      rescue WebAuthn::Error, JSON::ParserError
        @reauth_session.errors.add(:base, I18n.t("errors.webauthn.verification_failed"))
        false
      end

      def verify_success!
        now = Time.current
        ReauthSession.transaction do
          @reauth_session.update!(status: "VERIFIED", verified_at: now)
          @actor_token.update!(last_step_up_at: now, last_step_up_scope: @reauth_session.scope)
        end

        flash[:notice] = I18n.t("sign.app.reauth.success.complete")
        jump_to_generated_url(@reauth_session.return_to, fallback: sign_app_configuration_path(ri: params[:ri]))
      end
    end
  end
end
