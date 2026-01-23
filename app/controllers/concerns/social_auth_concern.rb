# frozen_string_literal: true

# Controller concern for handling OAuth social authentication flow.
# Provides intent/state management and callback processing.
#
# Intent Flow:
# 1. User visits /social_auth/start?intent=link
# 2. Controller calls prepare_social_auth_intent!("link")
# 3. User is redirected to OmniAuth provider
# 4. Provider redirects back to callback
# 5. Controller calls validate_social_auth_state! and process_social_auth_callback
#
# Security:
# - State parameter prevents CSRF attacks (applied to ALL providers including Apple)
# - Intent is stored in session, not passed via URL to prevent tampering
# - State expires after 5 minutes
module SocialAuthConcern
  extend ActiveSupport::Concern

  SOCIAL_INTENT_SESSION_KEY = :social_auth_intent
  STATE_TTL = 5.minutes
  REAUTH_TTL = 10.minutes

  VALID_INTENTS = %w(login link reauth).freeze

  included do
    rescue_from SocialAuth::BaseError, with: :handle_social_auth_error
    rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
  end

  # Prepare social auth intent before redirecting to OmniAuth provider.
  # Stores intent, state, and expiration in session.
  #
  # @param intent [String] One of: "login", "link", "reauth"
  # @return [String] The generated state parameter to pass to OmniAuth
  def prepare_social_auth_intent!(intent)
    intent = intent.to_s
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.invalid_intent") unless VALID_INTENTS.include?(intent)

    # For link/reauth, require logged-in user
    if %w(link reauth).include?(intent) && !logged_in?
      raise SocialAuth::UnauthorizedError.new("errors.social_auth.not_logged_in")
    end

    state = SecureRandom.hex(32)

    session[SOCIAL_INTENT_SESSION_KEY] = {
      "intent" => intent,
      "state" => state,
      "expires_at" => STATE_TTL.from_now.iso8601,
      "user_id" => current_resource&.id,
    }

    state
  end

  # Validate the state parameter from OmniAuth callback.
  # Must be called before processing the callback.
  #
  # IMPORTANT: State validation is applied to ALL providers including Apple.
  # Apple Sign In sends state back via POST body, which is extracted via params[:state].
  #
  # @raise [SocialAuth::UnauthorizedError] if state is invalid, missing, or expired
  def validate_social_auth_state!
    intent_data = session[SOCIAL_INTENT_SESSION_KEY]
    return if intent_data.blank?

    provider = omniauth_provider
    callback_state = extract_callback_state
    expected_state = intent_data["state"].to_s

    validate_state_presence!(callback_state, provider)
    validate_state_match!(expected_state, callback_state, provider)
    validate_state_expiry!(intent_data, provider)
    validate_user_consistency!(intent_data)
  end

  def validate_state_presence!(callback_state, provider)
    return if callback_state.present?

    Rails.event.notify("social_auth.state_missing", provider: provider)
    session.delete(SOCIAL_INTENT_SESSION_KEY)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.state_missing")
  end

  def validate_state_match!(expected_state, callback_state, provider)
    if ActiveSupport::SecurityUtils.secure_compare(expected_state, callback_state)
      return
    end

    Rails.event.notify(
      "social_auth.state_mismatch",
      provider: provider,
      expected_state_prefix: expected_state.first(8),
      actual_state_prefix: callback_state.first(8),
    )
    session.delete(SOCIAL_INTENT_SESSION_KEY)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.state_mismatch")
  end

  def validate_state_expiry!(intent_data, provider)
    expires_at = Time.zone.parse(intent_data["expires_at"]) rescue nil
    return if expires_at && Time.current <= expires_at

    Rails.event.notify(
      "social_auth.state_expired",
      provider: provider,
      expires_at: intent_data["expires_at"],
    )
    session.delete(SOCIAL_INTENT_SESSION_KEY)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.state_expired")
  end

  def validate_user_consistency!(intent_data)
    return unless %w(link reauth).include?(intent_data["intent"])

    if intent_data["user_id"] != current_resource&.id
      raise SocialAuth::UnauthorizedError.new("errors.social_auth.user_changed")
    end
  end

  # Extract state parameter from callback.
  # For Apple Sign In (POST), state is in the request body.
  # For Google (GET redirect), state is in query params.
  #
  # @return [String, nil] The state parameter
  def extract_callback_state
    # params[:state] works for both GET query string and POST body
    params[:state].to_s.presence
  end

  # Get the current social auth intent from session.
  # Returns "login" if no intent is set (backward compatibility).
  #
  # @return [String] The intent ("login", "link", or "reauth")
  def current_social_auth_intent
    intent_data = session[SOCIAL_INTENT_SESSION_KEY]
    intent_data&.dig("intent") || "login"
  end

  # Clear the social auth intent from session.
  # Should be called after successful callback processing.
  def clear_social_auth_intent!
    session.delete(SOCIAL_INTENT_SESSION_KEY)
  end

  # Require recent re-authentication for sensitive operations.
  # Checks if user.last_reauth_at is within the specified TTL.
  #
  # @param ttl [ActiveSupport::Duration] The time-to-live for reauth, defaults to REAUTH_TTL (10 minutes)
  # @raise [SocialAuth::ReauthRequiredError] if reauth is required
  def require_recent_reauth!(ttl: REAUTH_TTL)
    return unless current_resource

    last_reauth = current_resource.last_reauth_at

    if last_reauth.blank? || last_reauth < ttl.ago
      Rails.event.notify(
        "social_auth.reauth_required",
        user_id: current_resource.id,
        last_reauth_at: last_reauth&.iso8601,
        required_within: ttl.to_i,
      )
      raise SocialAuth::ReauthRequiredError.new("errors.social_auth.reauth_required")
    end
  end

  # Process the OmniAuth callback using SocialAuthService.
  #
  # @return [Hash] Result from SocialAuthService#handle_callback
  def process_social_auth_callback
    auth_hash = omniauth_auth_hash
    intent = current_social_auth_intent

    result = SocialAuthService.handle_callback(
      auth_hash: auth_hash,
      current_user: current_resource,
      intent: intent,
    )

    # Clear intent after successful processing
    clear_social_auth_intent!

    result
  end

  # Get the OmniAuth auth hash from the request environment.
  # IMPORTANT: Use request.env["omniauth.auth"], NOT params.
  #
  # @return [OmniAuth::AuthHash, nil]
  def omniauth_auth_hash
    request.env["omniauth.auth"]
  end

  # Get the OmniAuth provider from the auth hash.
  # IMPORTANT: Use auth hash provider, NOT params[:provider].
  #
  # @return [String, nil]
  def omniauth_provider
    omniauth_auth_hash&.provider
  end

  # Build the OmniAuth authorize path with state parameter.
  #
  # @param provider [String] e.g., "google_oauth2", "apple"
  # @param state [String] The state parameter
  # @return [String] The authorize path
  def omniauth_authorize_path(provider, state:)
    "/auth/#{provider}?state=#{CGI.escape(state)}"
  end

  private

  def handle_social_auth_error(error)
    Rails.event.notify(
      "social_auth.error",
      error_class: error.class.name,
      error_message: error.message,
      status_code: error.status_code,
    )

    respond_to do |format|
      format.html do
        flash[:alert] = error.message
        redirect_to social_auth_failure_redirect_path
      end
      format.json do
        render json: { error: error.message }, status: error.status_code
      end
    end
  end

  def handle_record_not_unique(error)
    Rails.event.notify(
      "social_auth.record_not_unique",
      error_message: error.message,
    )

    respond_to do |format|
      format.html do
        flash[:alert] = I18n.t("errors.social_auth.identity_conflict")
        redirect_to social_auth_failure_redirect_path
      end
      format.json do
        render json: { error: I18n.t("errors.social_auth.identity_conflict") }, status: :conflict
      end
    end
  end

  # Override this method to customize the failure redirect path
  def social_auth_failure_redirect_path
    respond_to?(:new_sign_app_in_path) ? new_sign_app_in_path : "/"
  end

  # Override this method to customize the success redirect path
  def social_auth_success_redirect_path
    respond_to?(:sign_app_root_path) ? sign_app_root_path : "/"
  end
end
