# FIXME: move to refresh_token and access_token models.

module Authn
  extend ActiveSupport::Concern

  # set url params
  #
  JWT_ALGORITHM = "ES256"
  ACCESS_TOKEN_EXPIRY = 15.minutes

  included do
    helper_method :logged_in?
  end

  # TODO: Implement!
  def sign_up(user_of_staff)
    # to avoid session saisei kougeki
    reset_session

    # create user or staff
    user = User.create

    # logged in
    begin
      log_in(user)
    rescue
      user.destroy
    end
  end

  # TODO: Implement!
  def log_in(user_or_staff)
    reset_session

    token = UserToken.create(user_id: user_or_staff.id)
    credentials = generate_access_token(token)

    # ACCESS_TOKEN: JWTは短期間（15分）
    cookies[:access_token] = {
      value: credentials,
      httponly: true,
      secure: Rails.env.production?,
      expires: ACCESS_TOKEN_EXPIRY.from_now
    }
    # REFRESH_TOKEN: 長期間（1年）
    cookies.encrypted[:refresh_token] = {
      value: token.id,
      httponly: true,
      secure: Rails.env.production?,
      expires: 1.year.from_now
    }

    # todo: redirect to
  end

  # TODO: Implement!
  def log_out
    # set cookie
    cookies.delete :access_token
    cookies.delete :refresh_token
  end

  # TODO: Implement!
  def logged_in?
    return false if cookies[:access_token].blank?

    begin
      verify_access_token(cookies[:access_token])
      true
    rescue JWT::ExpiredSignature, JWT::VerificationError
      false
    end
  end

  # TODO: Implement!
  def am_i_user?
    raise
  end

  # TODO: Implement!
  def am_i_staff?
    raise
  end

  # TODO: Implement!
  def am_i_owner?
    raise
  end

  def check_authentication
    user_id = 0
    staff_id = 0
    last_mfa_time = nil
    refresh_token_expires_at = 1.year.from_now

    cookies.encrypted[:access_token] = {
      value: { id: nil, user_id:, staff_id:, created_at: Time.zone.now, expires_at: nil },
      httponly: true,
      secure: Rails.env.production? ? true : false,
      expires: 30.seconds.from_now
    }
    cookies.encrypted[:refresh_token] = {
      value: { id: nil, user_id:, staff_id:, last_mfa_time:, created_at: Time.zone.now,
               expires_at: refresh_token_expires_at },
      httponly: true,
      secure: Rails.env.production? ? true : false,
      expires: refresh_token_expires_at
    }
  end

  def generate_access_token(user_or_staff)
    raise ArgumentError, "user_or_staff cannot be nil" if user_or_staff.nil?
    raise ArgumentError, "user_or_staff must respond to :id" unless user_or_staff.respond_to?(:id)
    raise ArgumentError, "user_or_staff id cannot be blank" if user_or_staff.id.blank?

    payload = {
      iat: Time.current.to_i,
      exp: ACCESS_TOKEN_EXPIRY.from_now.to_i,
      jti: SecureRandom.uuid,
      iss: request.host,
      aud: "umaxica-api",
      sub: user_or_staff.id,
      type: user_or_staff.class.name.downcase
    }

    key = jwt_private_key

    JWT.encode(payload, key, JWT_ALGORITHM)
  rescue StandardError => e
    Rails.logger.error "Failed to generate access token: #{e.message}"
    raise "Access token generation failed"
  end

  def verify_access_token(token)
    raise ArgumentError, "Token cannot be blank" if token.blank?

    key = jwt_public_key
    JWT.decode(token, key, true, {
      algorithm: JWT_ALGORITHM,
      verify_iat: true,
      verify_exp: true,
      verify_iss: true,
      iss: request.host,
      verify_aud: true,
      aud: "umaxica-api"
    }).first
  rescue JWT::ExpiredSignature
    Rails.logger.info "Expired token verification attempt"
    raise JWT::ExpiredSignature, "Token has expired"
  rescue JWT::DecodeError, JWT::VerificationError => e
    Rails.logger.warn "Token verification failed: #{e.class.name}"
    raise JWT::VerificationError, "Invalid token"
  rescue StandardError => e
    Rails.logger.error "Unexpected error during token verification: #{e.message}"
    raise JWT::VerificationError, "Token verification failed"
  end

  private

  def jwt_private_key
    @jwt_private_key ||= begin
                           private_key_base64 = Rails.application.credentials.JWT.PRIVATE_KEY
                           raise "JWT private key not configured in credentials" if private_key_base64.blank?

                           private_key_der = Base64.decode64(private_key_base64)
                           OpenSSL::PKey::EC.new(private_key_der)
                         end
  end

  def jwt_public_key
    @jwt_public_key ||= begin
                          public_key_base64 = Rails.application.credentials.JWT.PUBLIC_KEY
                          raise "JWT public key not configured in credentials" if public_key_base64.blank?

                          public_key_der = Base64.decode64(public_key_base64)
                          OpenSSL::PKey::EC.new(public_key_der)
                        end
  end

  private
end
