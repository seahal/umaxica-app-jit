# frozen_string_literal: true

module Sign
  module App
    # EmailRegistrationFlow
    #
    # Provides a complete email registration flow with OTP verification for both:
    # - New user signup (Sign::App::Up::EmailsController)
    # - Logged-in user email addition (Sign::App::Configuration::EmailsController)
    #
    # Uses SequentialFlow for step-based state management:
    #   Step 1: new/create - Email input and OTP initiation
    #   Step 2: edit/update - OTP verification
    #   Step 3: show/destroy - Confirmation/completion
    #
    # == Usage:
    #
    #   class EmailsController < ApplicationController
    #     include Sign::App::EmailRegistrationFlow
    #
    #     before_action :enforce_flow!, only: %i[edit update show]
    #
    #     def create
    #       if initiate_email_registration(email_params[:address], **options)
    #         advance_step!
    #         redirect_to edit_path(@user_email)
    #       else
    #         render :new, status: :unprocessable_content
    #       end
    #     end
    #
    #     def update
    #       result = complete_email_registration(params[:id], params[:pass_code]) do |email|
    #         # Custom logic: link email to user, etc.
    #       end
    #       handle_verification_result(result)
    #     end
    #   end
    #
    module EmailRegistrationFlow
      extend ActiveSupport::Concern

      include ::SequentialFlow
      include ::CloudflareTurnstile
      include Common::Otp

      EMAIL_STATUSES = {
        unverified: "UNVERIFIED_WITH_SIGN_UP",
        verified: "VERIFIED_WITH_SIGN_UP"
      }.freeze

      included do
        flow :email_registration do
          step 1, actions: %i[new create]
          step 2, actions: %i[edit update]
          step 3, actions: %i[show destroy]
        end
      end

      # Initiates email verification by creating a UserEmail record and sending OTP
      #
      # @param email_address [String] the email address to verify
      # @param confirm_policy [String] confirmation policy acceptance ("1" for accepted)
      # @param validate_turnstile [Boolean] whether to validate Cloudflare Turnstile
      # @param status [String] initial status for the email record
      # @return [Boolean] true if successful, false if validation failed
      def initiate_email_registration(email_address, confirm_policy: "1", validate_turnstile: true, status: EMAIL_STATUSES[:unverified])
        if validate_turnstile
          turnstile_result = cloudflare_turnstile_validation
          unless turnstile_result["success"]
            @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
            @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
            return false
          end
        end

        @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
        @user_email.user_email_status_id = status

        # Delete existing unverified email for same address
        UserEmail.where(
          address: @user_email.address,
          user_email_status_id: EMAIL_STATUSES[:unverified]
        ).destroy_all

        # Generate OTP
        otp_code = generate_otp_attributes(@user_email)

        return false unless @user_email.valid?

        @user_email.save!

        verification_token = @user_email.generate_verification_token

        Email::App::RegistrationMailer.with(
          hotp_token: otp_code,
          email_address: @user_email.address,
          verification_token: verification_token,
          public_id: @user_email.public_id
        ).create.deliver_later

        true
      end

      # Completes email verification by validating the OTP code
      #
      # @param public_id [String] the public_id of the UserEmail record
      # @param submitted_code [String] the OTP code submitted by the user
      # @param token [String, nil] optional verification token for direct link verification
      # @yield [UserEmail] block to execute on successful verification (e.g., link to user)
      # @return [Symbol] :success, :session_expired, :invalid_token, :locked, or :invalid_code
      def complete_email_registration(public_id, submitted_code, token = nil)
        @user_email = UserEmail.find_by(public_id: public_id)

        if @user_email.blank? ||
           @user_email.otp_expired? ||
           @user_email.user_email_status_id != EMAIL_STATUSES[:unverified]
          return :session_expired
        end

        # Verify token if provided (strict verification)
        if token.present?
          unless @user_email.verify_verification_token(token)
            @user_email.errors.add(:base, t("sign.app.registration.email.update.invalid_token"))
            return :invalid_token
          end
        end

        result = verify_otp_code(@user_email, submitted_code)

        unless result[:success]
          increment_otp_attempts!(@user_email)
          if @user_email.locked?
            @user_email.destroy!
            return :locked
          end
          @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
          return :invalid_code
        end

        clear_otp(@user_email)
        @user_email.user_email_status_id = EMAIL_STATUSES[:verified]

        yield(@user_email) if block_given?

        :success
      end

      # Loads and validates the email record for edit/update actions
      #
      # @param public_id [String] the public_id of the UserEmail record
      # @return [Boolean] true if valid, false and redirects if invalid
      def load_email_for_verification(public_id)
        @user_email = UserEmail.find_by(public_id: public_id)
        @verification_token = params[:token]

        if @user_email.blank? ||
           @user_email.otp_expired? ||
           @user_email.user_email_status_id != EMAIL_STATUSES[:unverified]
          reset_flow!
          flash[:alert] = t("sign.app.registration.email.edit.session_expired")
          return false
        end

        true
      end

      private

        # Override SequentialFlow's flow_initial_path
        def flow_initial_path
          raise NotImplementedError, "Override #flow_initial_path in your controller"
        end
    end
  end
end
