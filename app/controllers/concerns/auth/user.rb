# frozen_string_literal: true

module Auth
  module User
    extend ActiveSupport::Concern

    # TODO: Remove app/controllers/concerns/auth once all legacy references are deleted.
    include Auth::Base

    # Export core constants from Auth::Base for backward compatibility
    %i(
      ACCESS_COOKIE_KEY REFRESH_COOKIE_KEY DEVICE_COOKIE_KEY
      ACCESS_TOKEN_TTL REFRESH_TOKEN_TTL AUDIT_EVENTS
    ).each { |c| const_set(c, Auth::Base.const_get(c)) }

    include ::Authentication::User
    include ::Authorization::User
    include ::Verification::User
  end
end
