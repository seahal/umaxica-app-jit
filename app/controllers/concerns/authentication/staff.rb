# frozen_string_literal: true

module Authentication
  module Staff
    include Authentication::Base
    extend ActiveSupport::Concern

    included do
      # Add any instance methods or callbacks here
    end

    class_methods do
      # Add any class methods here
    end

    def current_staff
      return @current_staff if defined?(@current_staff)

      # Test helpers can inject current staff via request header
      if Rails.env.test? && respond_to?(:request) && request && (test_staff_id = request.headers["X-TEST-CURRENT-STAFF"])
        @current_staff = ::Staff.find_by(id: test_staff_id)
        return @current_staff
      end

      # JWT authentication via cookie
      if cookies[:auth_token].present?
        begin
          payload = verify_jwt_token(cookies[:auth_token])
          if payload["type"] == "staff"
            @current_staff = ::Staff.find_by(id: payload["sub"])
            # Treat withdrawn accounts as unauthenticated
            @current_staff = nil if @current_staff&.respond_to?(:withdrawn?) && @current_staff.withdrawn?
          end
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          @current_staff = nil
          # Clear invalid token
          cookies.delete(:auth_token)
        end
      end

      # Fallback to session-based authentication
      if @current_staff.nil?
        staff_data = session[:staff]
        @current_staff = ::Staff.find_by(id: staff_data[:id]) if staff_data&.dig(:id).present?
      end

      @current_staff
    end

    def logged_in?
      current_staff.present?
    end

    private

    def current_user
      raise NotImplementedError, "current_staff must not use Authentication::User"
    end

    def logged_in_staff?
      !!current_staff
    end

    def logged_in_user?
      raise NotImplementedError, "logged_in_staff? must not use Authentication::User"
    end

    def authenticate!
      unless logged_in_staff?
        if request.format.json?
          render json: { error: "Unauthorized" }, status: :unauthorized
          nil
        else
          head :unauthorized
          nil
        end
      end
    end

    def log_in(staff)
      reset_session

      # Generate JWT token
      token = generate_jwt_token(staff)

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
      session[:staff] = { id: staff.id }

      # Record login history
      record_login_audit(staff)
    end

    def log_out
      # Record logout history before clearing staff
      record_logout_audit(current_staff) if current_staff.present?

      # Clear JWT cookie
      cookies.delete(:auth_token, domain: :all)

      # Clear session
      reset_session
      @current_staff = nil
    end

    # JWT helper methods
    def generate_jwt_token(staff)
      payload = {
        sub: staff.id,                     # Subject (staff ID)
        type: "staff",                      # User or Staff
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
    def record_login_audit(staff)
      return unless staff.is_a?(::Staff)

      StaffIdentityAudit.create!(
        staff: staff,
        event_id: "LOGGED_IN",
        timestamp: Time.current,
        ip_address: request_ip_address,
        actor: staff
      )
    rescue => e
      # Log error but don't prevent login
      Rails.logger.error("Failed to record login audit: #{e.message}")
    end

    def record_logout_audit(staff)
      return unless staff.is_a?(::Staff)

      StaffIdentityAudit.create!(
        staff: staff,
        event_id: "LOGGED_OUT",
        timestamp: Time.current,
        ip_address: request_ip_address,
        actor: staff
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
