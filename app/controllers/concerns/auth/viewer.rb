# frozen_string_literal: true

module Auth
  module Viewer
    extend ActiveSupport::Concern

    include Auth::Base

    # Export core constants from Auth::Base for backward compatibility
    %i(
      ACCESS_COOKIE_KEY REFRESH_COOKIE_KEY DEVICE_COOKIE_KEY
      ACCESS_TOKEN_TTL REFRESH_TOKEN_TTL AUDIT_EVENTS
    ).each { |c| const_set(c, Auth::Base.const_get(c)) }

    include ::Authentication::Viewer
    include ::Authorization::Viewer
    include ::Verification::Viewer
  end
end
