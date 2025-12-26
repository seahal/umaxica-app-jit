# frozen_string_literal: true

# Rotates refresh tokens using the public_id/verifier format.
# Keeps verification centralized and raises a dedicated error on failure.
module Auth
  class RefreshTokenService
    def self.call(refresh_token:)
      new(refresh_token).call
    end

    def initialize(refresh_token)
      @refresh_token = refresh_token
    end

    def call
      public_id, verifier = parse_refresh_token!
      token = find_token(public_id)
      raise InvalidRefreshToken, "token_not_found" unless token
      raise InvalidRefreshToken, "inactive_token" unless token.active?
      raise InvalidRefreshToken, "invalid_verifier" unless token.authenticate_refresh_token(verifier)

      { token: token, refresh_token: token.rotate_refresh_token! }
    end

    private

    def parse_refresh_token!
      parsed = UserToken.parse_refresh_token(@refresh_token)
      raise InvalidRefreshToken, "invalid_format" unless parsed

      parsed
    end

    def find_token(public_id)
      UserToken.find_by(public_id: public_id) || StaffToken.find_by(public_id: public_id)
    end
  end
end
