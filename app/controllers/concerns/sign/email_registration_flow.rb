# frozen_string_literal: true

module Sign
  module EmailRegistrationFlow
    extend ActiveSupport::Concern

    include Sign::EmailRegistrable
    include Common::Redirect

    included do
      skip_before_action :enforce_email_flow!
    end

    def new
      @user_email = UserEmail.new
    end

    def edit
      @user_email = current_registration_email
      @verification_token = params[:token]
      return if valid_registration_email_session?

      reset_email_registration_flow!
      redirect_to new_registration_path_with_notice
    end

    def create
      email_params = params.expect(user_email: [:raw_address, :address])
      confirm_policy = params.dig(:user_email, :confirm_policy)
      email_address = email_params[:raw_address] || email_params[:address]

      unless initiate_email_verification!(
        email_address,
        confirm_policy: confirm_policy || "1",
      )
        render :new, status: :unprocessable_content
        return
      end

      session[registration_email_session_key] = @user_email.public_id

      redirect_params = build_notice_params(t("sign.app.registration.email.create.verification_code_sent"))
      flash[:notice] = redirect_params.delete(:notice)
      sanitize_redirect_params!(redirect_params)
      redirect_to after_email_registration_started_path(redirect_params)
    end

    def update
      @user_email = current_registration_email

      unless valid_registration_email_session?
        reset_email_registration_flow!
        redirect_to new_registration_path_with_notice
        return
      end

      submitted_code = params.dig(:user_email, :pass_code)
      if submitted_code.blank?
        @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.code_required"))
        render :edit, status: :unprocessable_content
        return
      end

      result =
        complete_email_verification!(
          @user_email.public_id, submitted_code,
          params.dig(:user_email, :token),
        ) do |user_email|
          finalize_registered_email!(user_email)
        end

      if result == :locked
        reset_email_registration_flow!
        flash[:alert] = t("sign.app.registration.email.update.attempts_exceeded")
        redirect_to new_email_registration_path
        return
      elsif !result
        render :edit, status: :unprocessable_content
        return
      end

      session.delete(registration_email_session_key)
      redirect_to after_email_registration_verified_path,
                  notice: t("sign.app.registration.email.update.success")
    end

    private

    def build_user_email(email_address, confirm_policy)
      super
      target_user = email_registration_target_user
      @user_email.user = target_user if target_user
    end

    def create_pending_user!
      target_user = email_registration_target_user
      return super unless target_user

      @user_email.user = target_user
    end

    def current_registration_email
      user_email = UserEmail.find_by(public_id: session[registration_email_session_key])
      return user_email if user_email.present?

      target_user = email_registration_target_user
      return nil unless target_user

      user_email =
        target_user
          .user_emails
          .where(user_email_status_id: UserEmailStatus::UNVERIFIED_WITH_SIGN_UP)
          .order(created_at: :desc)
          .first

      if user_email
        session[registration_email_session_key] = user_email.public_id
      end

      user_email
    end

    def valid_registration_email_session?
      @user_email.present? &&
        !@user_email.otp_expired? &&
        @user_email.user_email_status_id == UserEmailStatus::UNVERIFIED_WITH_SIGN_UP
    end

    def registration_email_session_key
      :email_registration_public_id
    end

    def reset_email_registration_flow!
      session.delete(registration_email_session_key)
      reset_email_flow!
    end

    def new_registration_path_with_notice
      redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
      flash[:notice] = redirect_params.delete(:notice)
      new_email_registration_path(redirect_params)
    end

    def sanitize_redirect_params!(redirect_params)
      return if redirect_params[:rd].blank?

      redirect_params[:rd] = sanitize_encoded_redirect(redirect_params[:rd])
      redirect_params.delete(:rd) if redirect_params[:rd].blank?
    end

    def sanitize_encoded_redirect(encoded_url)
      return if encoded_url.blank?

      decoded_url = Base64.urlsafe_decode64(encoded_url)
      safe_path = safe_internal_path(decoded_url)

      if safe_path
        Base64.urlsafe_encode64(safe_path)
      elsif safe_external_url?(decoded_url)
        Base64.urlsafe_encode64(decoded_url)
      end
    rescue ArgumentError, URI::InvalidURIError
      nil
    end

    def finalize_registered_email!(user_email)
      target_user = email_registration_target_user || user_email.user
      user_email.user = target_user
      user_email.save!

      if target_user.status_id == UserStatus::UNVERIFIED_WITH_SIGN_UP
        target_user.update!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
      end

      on_email_registration_verified!(user_email:, target_user:)
    end

    def on_email_registration_verified!(*)
      nil
    end

    def email_registration_target_user
      raise NotImplementedError, "#{self.class} must implement #email_registration_target_user"
    end

    def after_email_registration_started_path(_params = {})
      raise NotImplementedError, "#{self.class} must implement #after_email_registration_started_path"
    end

    def new_email_registration_path(_params = {})
      raise NotImplementedError, "#{self.class} must implement #new_email_registration_path"
    end

    def after_email_registration_verified_path
      raise NotImplementedError, "#{self.class} must implement #after_email_registration_verified_path"
    end
  end
end
