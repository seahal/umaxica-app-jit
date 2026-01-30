# frozen_string_literal: true

module Sign
  module EmailRegistrable
    extend ActiveSupport::Concern

    STATE_INIT = "init"
    STATE_EMAIL_CREATED = "email_created"
    STATE_EMAIL_VERIFIED = "email_verified"
    VALID_STATES = [STATE_INIT, STATE_EMAIL_CREATED, STATE_EMAIL_VERIFIED].freeze

    FLOW_REQUIREMENTS = {
      new: STATE_INIT,
      create: STATE_INIT,
      edit: STATE_EMAIL_CREATED,
      update: STATE_EMAIL_CREATED,
      show: STATE_EMAIL_VERIFIED,
      destroy: STATE_EMAIL_VERIFIED,
    }.freeze

    FLOW_PROGRESSIONS = {
      create: STATE_EMAIL_CREATED,
      update: STATE_EMAIL_VERIFIED,
      destroy: STATE_INIT,
    }.freeze

    SESSION_KEY = :sign_up_email_flow_state

    included do
      include ::CloudflareTurnstile
      include Common::Redirect
      include Common::Otp

      before_action :enforce_email_flow!, only: FLOW_REQUIREMENTS.keys
    end

    private

    def enforce_email_flow!
      required_state = FLOW_REQUIREMENTS[action_name.to_sym]
      return unless required_state

      current_state = email_flow_state
      return if current_state == required_state

      redirect_flow_violation
    end

    def email_flow_state
      current_state = session[SESSION_KEY]
      current_state = current_state.to_s if current_state.present?
      current_state = STATE_INIT unless VALID_STATES.include?(current_state)
      session[SESSION_KEY] = current_state
    end

    def progress_email_flow!(action)
      next_state = FLOW_PROGRESSIONS[action.to_sym]
      session[SESSION_KEY] = next_state if next_state
    end

    def reset_email_flow!
      session[SESSION_KEY] = STATE_INIT
    end

    def redirect_flow_violation
      flash[:alert] = t("sign.app.registration.email.flow.invalid")
      redirect_to new_sign_app_up_email_path
    end

    def initiate_email_verification!(email_address, confirm_policy: "1")
      # Validate Cloudflare Turnstile
      turnstile_result = cloudflare_turnstile_validation
      unless turnstile_result["success"]
        @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
        @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
        return false
      end

      @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
      @user_email.user_email_status_id = "UNVERIFIED_WITH_SIGN_UP"

      # Rate limit check (TODO: Implement rate limiting)
      # if rate_limited? ...

      begin
        UserEmail.transaction do
          # Delete existing unverified email
          UserEmail.where(
            address: @user_email.address,
            user_email_status_id: "UNVERIFIED_WITH_SIGN_UP",
          ).destroy_all

          # Generate OTP
          num = generate_otp_attributes(@user_email)

          @user_email.save!

          token = @user_email.generate_verification_token

          Email::App::RegistrationMailer.with(
            hotp_token: num,
            email_address: @user_email.address,
            verification_token: token,
            public_id: @user_email.public_id,
          ).create.deliver_later
        end
      rescue ActiveRecord::RecordInvalid => e
        @user_email = e.record
        return false
      end

      true
    end

    def complete_email_verification!(id, submitted_code, token = nil)
      @user_email = UserEmail.find_by(public_id: id)

      # Session validation should be done in controller
      # This method assumes valid session

      # Verify token if provided (strict verification)
      if token.present?
        unless @user_email.verify_verification_token(token)
          @user_email.errors.add(:base, t("sign.app.registration.email.update.invalid_token"))
          return false
        end
      end

      result = verify_otp_code(@user_email, submitted_code)

      unless result[:success]
        increment_otp_attempts!(@user_email)
        if @user_email.locked?
          @user_email.destroy!
          @user_email.errors.add(:base, :locked)
          return :locked
        end
        @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
        return false
      end

      begin
        @user_email.transaction do
          clear_otp(@user_email)
          @user_email.user_email_status_id = "VERIFIED_WITH_SIGN_UP"

          yield(@user_email) if block_given?
        end
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        # Transaction rolled back
        @user_email.errors.add(:base, e.message) if @user_email.errors.empty?
        return false
      end

      true
    end
  end
end
