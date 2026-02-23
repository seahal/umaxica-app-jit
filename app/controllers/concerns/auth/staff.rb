# typed: false
# frozen_string_literal: true

module Auth
  module Staff
    extend ActiveSupport::Concern

    include Auth::Base

    # Export core constants from Auth::Base for backward compatibility
    ACCESS_COOKIE_KEY = Auth::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Auth::Base::REFRESH_COOKIE_KEY
    DEVICE_COOKIE_KEY = Auth::Base::DEVICE_COOKIE_KEY
    ACCESS_TOKEN_TTL = Auth::Base::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = Auth::Base::REFRESH_TOKEN_TTL
    AUDIT_EVENTS = Auth::Base::AUDIT_EVENTS

    include ::Authentication::Staff
    include ::Authorization::Staff
    include ::Verification::Staff
  end
end
