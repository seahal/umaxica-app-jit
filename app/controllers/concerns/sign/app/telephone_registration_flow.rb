# typed: false
# frozen_string_literal: true

module Sign
  module App
    # TelephoneRegistrationFlow
    #
    # Provides a complete telephone registration flow with SMS OTP verification for both:
    # - New user signup (Sign::App::Up::TelephonesController)
    # - Logged-in user telephone addition (Sign::App::Configuration::TelephonesController)
    #
    # Uses SequentialFlow for step-based state management:
    #   Step 1: new/create - Telephone input and OTP initiation
    #   Step 2: edit/update - OTP verification
    #   Step 3: show/destroy - Confirmation/completion
    #
    # == Usage:
    #
    #   class TelephonesController < ApplicationController
    #     include Sign::App::TelephoneRegistrationFlow
    #
    #     before_action :enforce_flow!, only: %i[edit update show]
    #
    #     def create
    #       if initiate_telephone_registration(telephone_params[:number], **options)
    #         advance_step!
    #         redirect_to edit_path(@user_telephone)
    #       else
    #         render :new, status: :unprocessable_content
    #       end
    #     end
    #
    #     def update
    #       result = complete_telephone_registration(params[:id], params[:pass_code]) do |telephone|
    #         # Custom logic: link telephone to user, etc.
    #       end
    #       handle_verification_result(result)
    #     end
    #   end
    #
    module TelephoneRegistrationFlow
      extend ActiveSupport::Concern

      include ::SequentialFlow
      include ::CloudflareTurnstile
      include Common::Otp

      TELEPHONE_STATUSES = {
        unverified: "UNVERIFIED_WITH_SIGN_UP",
        verified: "VERIFIED_WITH_SIGN_UP",
      }.freeze

      included do
        flow :telephone_registration do
          step 1, actions: %i(new create)
          step 2, actions: %i(edit update)
          step 3, actions: %i(show destroy)
        end
      end

      # Initiates telephone verification by creating a UserTelephone record and sending SMS OTP
      #
      # @param telephone_number [String] the telephone number to verify (will be normalized to E.164)
      # @param confirm_policy [String] confirmation policy acceptance ("1" for accepted)
      # @param confirm_using_mfa [String] MFA confirmation ("1" for accepted)
      # @param validate_turnstile [Boolean] whether to validate Cloudflare Turnstile
      # @param status [String] initial status for the telephone record
      # @return [Boolean] true if successful, false if validation failed
      def initiate_telephone_registration(
        telephone_number,
        confirm_policy: "1",
        confirm_using_mfa: "1",
        validate_turnstile: false,
        status: TELEPHONE_STATUSES[:unverified]
      )
        if validate_turnstile
          turnstile_result = cloudflare_turnstile_validation
          unless turnstile_result["success"]
            @user_telephone = UserTelephone.new(
              number: telephone_number, confirm_policy: confirm_policy,
              confirm_using_mfa: confirm_using_mfa,
            )
            @user_telephone.errors.add(:base, t("sign.app.configuration.telephone.create.turnstile_validation_failed"))
            return false
          end
        end

        # Normalize telephone number (basic E.164 normalization)
        normalized_number = normalize_telephone_number(telephone_number)

        @user_telephone = UserTelephone.new(
          number: normalized_number, confirm_policy: confirm_policy,
          confirm_using_mfa: confirm_using_mfa,
        )
        @user_telephone.user_telephone_status_id = status

        # Check for global uniqueness (already verified numbers)
        if UserTelephone.exists?(number: normalized_number, user_telephone_status_id: TELEPHONE_STATUSES[:verified])
          @user_telephone.errors.add(:number, t("sign.app.configuration.telephone.create.already_registered"))
          return false
        end

        # Delete existing unverified telephone for same number
        UserTelephone.where(
          number: normalized_number,
          user_telephone_status_id: TELEPHONE_STATUSES[:unverified],
        ).destroy_all

        # Generate OTP
        otp_code = generate_otp_attributes(@user_telephone)

        return false unless @user_telephone.valid?

        @user_telephone.save!

        # Send SMS
        AwsSmsService.send_message(
          to: @user_telephone.number,
          message: "PassCode => #{otp_code}",
          subject: "PassCode => #{otp_code}",
        )

        true
      end

      # Completes telephone verification by validating the OTP code
      #
      # @param id [String] the id of the UserTelephone record
      # @param submitted_code [String] the OTP code submitted by the user
      # @yield [UserTelephone] block to execute on successful verification (e.g., link to user)
      # @return [Symbol] :success, :session_expired, :locked, or :invalid_code
      def complete_telephone_registration(id, submitted_code)
        @user_telephone = UserTelephone.find_by(id: id)

        if @user_telephone.blank? ||
            @user_telephone.otp_expired? ||
            @user_telephone.user_telephone_status_id != TELEPHONE_STATUSES[:unverified]
          return :session_expired
        end

        result = verify_otp_code(@user_telephone, submitted_code)

        unless result[:success]
          increment_otp_attempts!(@user_telephone)
          if @user_telephone.locked?
            @user_telephone.destroy!
            return :locked
          end
          @user_telephone.errors.add(:pass_code, t("sign.app.configuration.telephone.update.invalid_code"))
          return :invalid_code
        end

        clear_otp(@user_telephone)
        @user_telephone.user_telephone_status_id = TELEPHONE_STATUSES[:verified]

        yield(@user_telephone) if block_given?

        :success
      end

      # Loads and validates the telephone record for edit/update actions
      #
      # @param id [String] the id of the UserTelephone record
      # @return [Boolean] true if valid, false and redirects if invalid
      def load_telephone_for_verification(id)
        @user_telephone = UserTelephone.find_by(id: id)

        if @user_telephone.blank? ||
            @user_telephone.otp_expired? ||
            @user_telephone.user_telephone_status_id != TELEPHONE_STATUSES[:unverified]
          reset_flow!
          flash[:alert] = t("sign.app.configuration.telephone.edit.session_expired")
          return false
        end

        true
      end

      private

      # Normalizes telephone number to E.164 format
      # Basic normalization: removes spaces, parentheses, hyphens
      # For production, consider using a library like phonelib for full E.164 normalization
      #
      # @param number [String] the raw telephone number
      # @return [String] normalized telephone number
      def normalize_telephone_number(number)
        return "" if number.blank?

        # Remove common formatting characters
        normalized = number.gsub(/[\s\-\(\)]/, "")

        # Ensure it starts with + for international format
        normalized = "+#{normalized}" unless normalized.start_with?("+")

        normalized
      end

      # Override SequentialFlow's flow_initial_path
      def flow_initial_path
        raise NotImplementedError, "Override #flow_initial_path in your controller"
      end
    end
  end
end
