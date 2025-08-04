module AccessToken
  extend ActiveSupport::Concern

  JWT_ALGORITHM = "ES256"
  ACCESS_TOKEN_EXPIRY = 30.minutes

  # included do
  #   # Skip CSRF protection for API endpoints
  #   skip_before_action :verify_authenticity_token, if: :api_request?
  #   before_action :authenticate_with_access_token, if: :api_request?
  # end

  public
  def generate_access_token(user_or_staff)
    # FIXME: Implement!
  end

  def verify_access_token(token)
    # FIXME: Implement!
  end


  private

  # def api_request?
  #   request.path.start_with?("/api/") ||
  #     request.format.json? ||
  #     bearer_token.present?
  # end
  #
  # def jwt_private_key
  #   @jwt_private_key ||= if Rails.env.production?
  #     # Production: Use encrypted ECDSA key from credentials
  #     OpenSSL::PKey::EC.new(
  #       Rails.application.credentials.jwt_private_key ||
  #       raise("JWT private key not configured in credentials")
  #     )
  #   else
  #     # Development: Generate or load ECDSA key
  #     load_or_generate_ecdsa_key
  #   end
  # end
  #
  # def jwt_public_key
  #   @jwt_public_key ||= jwt_private_key.public_key
  # end
  #
  # def load_or_generate_ecdsa_key
  #   key_file = Rails.root.join("tmp", "jwt_ecdsa_key.pem")
  #
  #   if key_file.exist?
  #     OpenSSL::PKey::EC.new(File.read(key_file))
  #   else
  #     # Generate P-256 curve key for ES256
  #     key = OpenSSL::PKey::EC.generate("prime256v1")
  #     File.write(key_file, key.to_pem)
  #     Rails.logger.info "Generated new ECDSA key for development: #{key_file}"
  #     key
  #   end
  # end
  #
  # def authenticate_with_access_token
  #   token = bearer_token
  #   return render_unauthorized unless token
  #
  #   begin
  #     payload = decode_access_token(token)
  #
  #     # Check if token is blacklisted
  #     return render_unauthorized if token_blacklisted?(payload["jti"])
  #
  #     @current_user = find_user_from_payload(payload)
  #     @current_staff = find_staff_from_payload(payload)
  #
  #     render_unauthorized unless @current_user || @current_staff
  #   rescue JWT::ExpiredSignature
  #     render_token_expired
  #   rescue JWT::DecodeError, JWT::VerificationError => e
  #     Rails.logger.warn "JWT verification failed: #{e.message}"
  #     render_unauthorized
  #   end
  # end
  #
  # def bearer_token
  #   header = request.headers["Authorization"]
  #   return nil unless header&.start_with?("Bearer ")
  #   header.split(" ").last
  # end
  #
  # def generate_access_token(user: nil, staff: nil)
  #   payload = {
  #     iat: Time.current.to_i,
  #     exp: ACCESS_TOKEN_EXPIRY.from_now.to_i,
  #     jti: SecureRandom.uuid,
  #     iss: request.host,
  #     aud: "umaxica-api"
  #   }
  #
  #   if user
  #     payload[:sub] = user.id
  #     payload[:type] = "user"
  #     payload[:scope] = user_scopes(user)
  #   elsif staff
  #     payload[:sub] = staff.id
  #     payload[:type] = "staff"
  #     payload[:scope] = staff_scopes(staff)
  #   end
  #
  #   # ES256 uses ECDSA private key for signing
  #   JWT.encode(payload, jwt_private_key, JWT_ALGORITHM)
  # end
  #
  # def decode_access_token(token)
  #   # ES256 uses ECDSA public key for verification
  #   JWT.decode(token, jwt_public_key, true, {
  #     algorithm: JWT_ALGORITHM,
  #     verify_iat: true,
  #     verify_exp: true,
  #     verify_iss: true,
  #     iss: request.host,
  #     verify_aud: true,
  #     aud: "umaxica-api"
  #   }).first
  # end
  #
  # def find_user_from_payload(payload)
  #   return nil unless payload["type"] == "user"
  #   User.find_by(id: payload["sub"])
  # end
  #
  # def find_staff_from_payload(payload)
  #   return nil unless payload["type"] == "staff"
  #   Staff.find_by(id: payload["sub"])
  # end
  #
  # def user_scopes(user)
  #   scopes = ["read", "write"]
  #   scopes << "admin" if user.respond_to?(:admin?) && user.admin?
  #   scopes
  # end
  #
  # def staff_scopes(staff)
  #   scopes = ["read", "write", "staff"]
  #   scopes << "admin" if staff.respond_to?(:admin?) && staff.admin?
  #   scopes
  # end
  #
  # def current_user_from_token
  #   @current_user
  # end
  #
  # def current_staff_from_token
  #   @current_staff
  # end
  #
  # def render_unauthorized
  #   render json: {
  #     error: "unauthorized",
  #     message: "Invalid or missing access token"
  #   }, status: :unauthorized
  # end
  #
  # def render_token_expired
  #   render json: {
  #     error: "token_expired",
  #     message: "Access token has expired"
  #   }, status: :unauthorized
  # end
  #
  # # Redis cache for token blacklisting
  # def blacklist_token(jti)
  #   Rails.cache.write("blacklisted_token:#{jti}", true, expires_in: ACCESS_TOKEN_EXPIRY)
  # end
  #
  # def token_blacklisted?(jti)
  #   return false if jti.blank?
  #   Rails.cache.exist?("blacklisted_token:#{jti}")
  # end
end
