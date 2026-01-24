# frozen_string_literal: true

# Handles OAuth social authentication callback processing.
# Supports login, link, and reauth intents.
#
# Usage:
#   result = SocialAuthService.handle_callback(
#     auth_hash: request.env["omniauth.auth"],
#     current_user: current_user,
#     intent: "login"
#   )
#   # => { user: User, identity: UserSocialGoogle, jwt_payload: {...} }
#
#   SocialAuthService.unlink(provider: "google", user: user)
#
class SocialAuthService
  VALID_INTENTS = %w(login link reauth).freeze

  class << self
    def handle_callback(auth_hash:, current_user:, intent:)
      new(auth_hash:, current_user:, intent:).handle_callback
    end

    def unlink(provider:, user:)
      new(auth_hash: nil, current_user: user, intent: nil).unlink(provider)
    end
  end

  def initialize(auth_hash:, current_user:, intent:)
    @auth_hash = auth_hash
    @current_user = current_user
    @intent = intent&.to_s
  end

  def handle_callback
    validate_intent! if @intent.present?
    validate_auth_hash!

    provider = extract_provider
    uid = extract_uid
    identity_class = SocialIdentifiable.model_for_provider(provider)

    PrincipalRecord.transaction do
      case @intent
      when "login", nil
        handle_login(identity_class, provider, uid)
      when "link"
        handle_link(identity_class, provider, uid)
      when "reauth"
        handle_reauth(identity_class, provider, uid)
      end
    end
  end

  def unlink(provider)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.not_logged_in") unless @current_user

    identity_class = SocialIdentifiable.model_for_provider(provider)
    identity = identity_for_user(identity_class, provider)

    raise SocialAuth::ProviderError.new("errors.social_auth.identity_not_found", provider: provider) unless identity

    PrincipalRecord.transaction do
      # Lock the user to prevent race conditions
      @current_user.lock!

      # Check if this is the last authentication method
      if last_authentication_method?
        raise SocialAuth::LastIdentityError.new("errors.social_auth.last_identity")
      end

      # Soft delete: set status to REVOKED instead of destroying
      revoked_status =
        case identity_class.name
        when "UserSocialGoogle"
          UserSocialGoogleStatus::REVOKED
        when "UserSocialApple"
          UserSocialAppleStatus::REVOKED
        end

      identity.update!(identity_class.status_column => revoked_status)

      Rails.event.notify(
        "social_auth.unlinked",
        user_id: @current_user.id,
        provider: provider,
      )
    end

    { success: true, provider: provider }
  end

  private

  def validate_intent!
    return if VALID_INTENTS.include?(@intent)

    raise SocialAuth::UnauthorizedError.new(
      "errors.social_auth.invalid_intent",
      intent: @intent,
    )
  end

  def validate_auth_hash!
    raise SocialAuth::ProviderError.new("errors.social_auth.missing_auth_hash") unless @auth_hash
  end

  def extract_provider
    provider = @auth_hash["provider"] || @auth_hash[:provider]
    raise SocialAuth::ProviderError.new("errors.social_auth.missing_provider") if provider.blank?

    provider.to_s
  end

  def extract_uid
    uid = @auth_hash["uid"] || @auth_hash[:uid]

    # Fallback chain for uid extraction (especially important for Apple)
    if uid.blank?
      # Try extra.raw_info.sub (standard OIDC)
      raw_info = @auth_hash.dig("extra", "raw_info") || @auth_hash.dig(:extra, :raw_info)
      uid = raw_info&.dig("sub") || raw_info&.dig(:sub)
    end

    if uid.blank?
      # Try id_info.sub (omniauth-apple specific)
      id_info = @auth_hash.dig("extra", "id_info") || @auth_hash.dig(:extra, :id_info)
      uid = id_info&.dig("sub") || id_info&.dig(:sub)
    end

    if uid.blank?
      # Last resort: decode id_token directly (Apple)
      uid = extract_uid_from_id_token
    end

    raise SocialAuth::ProviderError.new("errors.social_auth.missing_uid") if uid.blank?

    uid.to_s
  end

  # Extract uid (sub claim) from Apple's id_token by decoding JWT payload
  # This is a fallback when omniauth-apple doesn't populate uid correctly
  def extract_uid_from_id_token
    id_token = @auth_hash.dig("credentials", "id_token")
    id_token ||= @auth_hash.dig(:credentials, :id_token)
    return nil if id_token.blank?

    # Decode JWT without verification (we just need the sub claim)
    # The token has already been verified by omniauth-apple
    payload = JWT.decode(id_token, nil, false).first
    payload["sub"]
  rescue JWT::DecodeError => e
    Rails.logger.warn("[SocialAuth] Failed to decode id_token: #{e.message}")
    nil
  end

  # Intent: login (or nil for backward compatibility)
  # - If identity exists with user -> sign in
  # - If identity exists without user -> create user and sign in
  # - If identity doesn't exist -> create identity and user, sign in
  def handle_login(identity_class, provider, uid)
    identity = identity_class.lock.find_by(uid: uid, provider: provider)

    if identity
      # Existing identity
      user = identity.user
      unless user
        # Orphaned identity - create user
        user = create_user_for_identity(identity, identity_class, provider)
      end

      identity.update_from_auth_hash!(@auth_hash)
      build_result(user, identity, reauthenticated: false, existing_account: true)
    else
      # New identity - create user and identity
      user = User.new(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
      identity = build_identity_for_user(identity_class, user, provider, uid)

      user.save!
      identity.save!
      identity.touch_authenticated!

      build_result(user, identity, reauthenticated: false, existing_account: false)
    end
  rescue ActiveRecord::RecordNotUnique => e
    # Race condition: identity was created between check and insert
    Rails.event.notify(
      "social_auth.race_condition",
      provider: provider,
      uid: uid,
      error: e.message,
    )
    raise SocialAuth::ConflictError.new("errors.social_auth.identity_conflict")
  end

  # Intent: link
  # - Requires current_user
  # - If identity exists and belongs to another user -> 409 Conflict
  # - If identity exists and belongs to current_user -> update and return (reactivate if REVOKED)
  # - If identity doesn't exist -> create and link to current_user
  def handle_link(identity_class, provider, uid)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.not_logged_in") unless @current_user

    # Check if user already has this provider linked
    existing_for_user = identity_for_user(identity_class, provider)
    if existing_for_user
      # User already has this provider - update and ensure it's ACTIVE
      existing_for_user.update_from_auth_hash!(@auth_hash)

      # Reactivate if it was REVOKED
      active_status =
        case identity_class.name
        when "UserSocialGoogle"
          UserSocialGoogleStatus::ACTIVE
        when "UserSocialApple"
          UserSocialAppleStatus::ACTIVE
        end

      existing_for_user.update!(identity_class.status_column => active_status)
      return build_result(@current_user, existing_for_user, reauthenticated: false)
    end

    identity = identity_class.lock.find_by(uid: uid, provider: provider)

    if identity
      # Identity exists
      if identity.user_id != @current_user.id
        # Belongs to another user - conflict
        raise SocialAuth::ConflictError.new(
          "errors.social_auth.linked_to_another_user",
          provider: SocialIdentifiable.normalize_provider(provider),
        )
      end

      # Belongs to current user (shouldn't happen due to unique constraint, but handle it)
      identity.update_from_auth_hash!(@auth_hash)
      build_result(@current_user, identity, reauthenticated: false)
    else
      # Create new identity for current user
      identity = build_identity_for_user(identity_class, @current_user, provider, uid)
      identity.save!
      identity.touch_authenticated!

      Rails.event.notify(
        "social_auth.linked",
        user_id: @current_user.id,
        provider: provider,
      )

      build_result(@current_user, identity, reauthenticated: false)
    end
  rescue ActiveRecord::RecordNotUnique => e
    Rails.event.notify(
      "social_auth.link_race_condition",
      user_id: @current_user.id,
      provider: provider,
      uid: uid,
      error: e.message,
    )
    raise SocialAuth::ConflictError.new("errors.social_auth.identity_conflict")
  end

  # Intent: reauth
  # - Requires current_user
  # - Identity must belong to current_user
  # - Updates user.last_reauth_at
  # - JWT payload includes reauthenticated_at
  def handle_reauth(identity_class, provider, uid)
    raise SocialAuth::UnauthorizedError.new("errors.social_auth.not_logged_in") unless @current_user

    identity = identity_class.lock.find_by(uid: uid, provider: provider)

    unless identity && identity.user_id == @current_user.id
      raise SocialAuth::UnauthorizedError.new(
        "errors.social_auth.reauth_identity_mismatch",
        provider: SocialIdentifiable.normalize_provider(provider),
      )
    end

    now = Time.current
    identity.update_from_auth_hash!(@auth_hash)
    @current_user.update!(last_reauth_at: now)

    Rails.event.notify(
      "social_auth.reauthenticated",
      user_id: @current_user.id,
      provider: provider,
    )

    build_result(@current_user, identity, reauthenticated: true, reauth_at: now)
  end

  def create_user_for_identity(identity, identity_class, provider)
    user = User.new(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
    assign_identity_to_user(user, identity, identity_class, provider)
    user.save!
    identity.update!(user: user)
    user
  end

  def build_identity_for_user(identity_class, user, provider, uid)
    identity = identity_class.new(
      uid: uid,
      provider: provider,
      email: @auth_hash.dig("info", "email") || @auth_hash.dig(:info, :email) || "",
      image: @auth_hash.dig("info", "image") || @auth_hash.dig(:info, :image) || "",
      token: @auth_hash.dig("credentials", "token") || @auth_hash.dig(:credentials, :token) || "",
      refresh_token: @auth_hash.dig(
        "credentials",
        "refresh_token",
      ) || @auth_hash.dig(:credentials, :refresh_token) || "",
      expires_at: @auth_hash.dig("credentials", "expires_at") || @auth_hash.dig(:credentials, :expires_at) || 0,
    )
    assign_identity_to_user(user, identity, identity_class, provider)
    identity
  end

  def assign_identity_to_user(user, identity, identity_class, provider)
    case identity_class.name
    when "UserSocialGoogle"
      user.user_social_google = identity
      identity.user = user
    when "UserSocialApple"
      user.user_social_apple = identity
      identity.user = user
    end
  end

  def identity_for_user(identity_class, provider)
    case identity_class.name
    when "UserSocialGoogle"
      @current_user.user_social_google
    when "UserSocialApple"
      @current_user.user_social_apple
    end
  end

  def last_authentication_method?
    auth_methods_count = 0

    # Count social identities (only ACTIVE ones)
    google = @current_user.user_social_google
    if google&.user_identity_social_google_status_id == UserSocialGoogleStatus::ACTIVE
      auth_methods_count += 1
    end

    apple = @current_user.user_social_apple
    if apple&.user_identity_social_apple_status_id == UserSocialAppleStatus::ACTIVE
      auth_methods_count += 1
    end

    # Count other auth methods (email, telephone, passkey, secret)
    if @current_user.respond_to?(:user_emails)
      # UserEmailStatus uses VERIFIED/VERIFIED_WITH_SIGN_UP, not ACTIVE
      auth_methods_count += @current_user.user_emails.where(
        user_email_status_id: %w(ACTIVE VERIFIED VERIFIED_WITH_SIGN_UP),
      ).count
    end

    if @current_user.respond_to?(:user_telephones)
      auth_methods_count += @current_user.user_telephones.where(user_telephone_status_id: "ACTIVE").count
    end

    if @current_user.respond_to?(:user_passkeys)
      auth_methods_count += @current_user.user_passkeys.where(user_passkey_status_id: "ACTIVE").count
    end

    if @current_user.respond_to?(:user_secrets)
      auth_methods_count += @current_user.user_secrets.where(user_secret_status_id: "ACTIVE").count
    end

    auth_methods_count <= 1
  end

  def build_result(user, identity, reauthenticated:, reauth_at: nil, existing_account: nil)
    jwt_payload = { user_id: user.id }
    jwt_payload[:reauthenticated_at] = reauth_at.iso8601 if reauthenticated && reauth_at

    {
      user: user,
      identity: identity,
      jwt_payload: jwt_payload,
      reauthenticated: reauthenticated,
      existing_account: existing_account,
    }
  end
end
