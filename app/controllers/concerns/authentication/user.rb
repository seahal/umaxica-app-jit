# frozen_string_literal: true

module Authentication
  module User
    include Authentication::Base
    extend ActiveSupport::Concern

    included do
      # Add any instance methods or callbacks here
    end

    class_methods do
      # Add any class methods here
    end

    def current_user
      return @current_user if defined?(@current_user)

      # Test helpers can inject a current user via request header to support
      # controller instance dispatch in tests. Only allow this in the test
      # environment to avoid an authentication backdoor in production.
      if Rails.env.test? && respond_to?(:request) && request && (test_user_id = request.headers["X-TEST-CURRENT-USER"])
        @current_user = ::User.find_by(id: test_user_id)
        return @current_user
      end

      # JWT authentication via cookie
      if cookies[:auth_token].present?
        begin
          payload = verify_jwt_token(cookies[:auth_token])
          if payload["type"] == "user"
            @current_user = ::User.find_by(id: payload["sub"])
            # Treat withdrawn accounts as unauthenticated
            @current_user = nil if @current_user&.respond_to?(:withdrawn?) && @current_user.withdrawn?
          end
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          @current_user = nil
          # Clear invalid token
          cookies.delete(:auth_token)
        end
      end

      # Fallback to session-based authentication (for backward compatibility)
      if @current_user.nil?
        user_id = session[:user]&.dig(:id) || session[:user_id]
        @current_user = ::User.find_by(id: user_id) if user_id.present?
      end

      @current_user
    end

    def logged_in?
      # Check if current_user is present
      return true if current_user.present?

      # Also check current_staff from Authn concern if it was set
      # (Authn concern sets @current_staff directly, bypassing our current_staff method)
      if instance_variable_defined?(:@current_staff) && instance_variable_get(:@current_staff).present?
        return true
      end

      false
    end

    private

    def current_staff
      raise NotImplementedError, "current_staff must not use Authentication::User"
    end

    def log_in(user)
      reset_session

      # Generate JWT token
      token = generate_jwt_token(user)

      # Set cookie (plain cookie for React to read)
      cookies[:auth_token] = {
        value: token,
        expires: 1.year.from_now,
        httponly: false,  # React needs to read this
        secure: Rails.env.production?,
        same_site: :lax,
        domain: :all  # Share across subdomains
      }

      # Also set session for backward compatibility
      session[:user_id] = user.id

      # Record login history
      record_login_audit(user)
    end

    def log_out
      # Record logout history before clearing user
      record_logout_audit(current_user) if current_user.present?

      # Clear JWT cookie
      cookies.delete(:auth_token, domain: :all)

      # Clear session
      reset_session
      @current_user = nil
    end

    def logged_in_user?
      logged_in?
    end

    def logged_in_staff?
      raise NotImplementedError, "logged_in_staff? must not use Authentication::User"
    end

    def authenticate!
      unless logged_in_user?
        if request.format.json?
          render json: { error: "Unauthorized" }, status: :unauthorized
          nil
        else
          head :unauthorized
          nil
        end
      end
    end

    # JWT helper methods
    def generate_jwt_token(user)
      payload = {
        sub: user.id,                      # Subject (user ID)
        type: "user",                       # User or Staff
        iat: Time.current.to_i,            # Issued at
        exp: 1.year.from_now.to_i,         # Expiration (1 year)
        jti: SecureRandom.uuid             # JWT ID (unique identifier)
      }

      # Add issuer if request is available
      payload[:iss] = request.host if respond_to?(:request) && request

      JWT.encode(payload, jwt_private_key, Authentication::Base::JWT_ALGORITHM)
    end

    def verify_jwt_token(token)
      JWT.decode(
        token,
        jwt_public_key,
        true,
        {
          algorithm: Authentication::Base::JWT_ALGORITHM,
          verify_iat: true,
          verify_exp: true
        }
      ).first
    end

    # Login history recording
    def record_login_audit(user)
      return unless user.is_a?(::User)

      UserIdentityAudit.create!(
        user: user,
        event_id: "LOGGED_IN",
        timestamp: Time.current,
        ip_address: request_ip_address,
        actor: user
      )
    rescue => e
      # Log error but don't prevent login
      Rails.logger.error("Failed to record login audit: #{e.message}")
    end

    def record_logout_audit(user)
      return unless user.is_a?(::User)

      UserIdentityAudit.create!(
        user: user,
        event_id: "LOGGED_OUT",
        timestamp: Time.current,
        ip_address: request_ip_address,
        actor: user
      )
    rescue => e
      # Log error but don't prevent logout
      Rails.logger.error("Failed to record logout audit: #{e.message}")
    end

    def request_ip_address
      if respond_to?(:request) && request
        request.remote_ip
      else
        nil
      end
    end

    # Add private helper methods here
  end
end
