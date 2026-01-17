# frozen_string_literal: true

module Edge
  module V1
    class BaseController < ApplicationController
      # Edge API is called from browser/SPA and uses Cookie-based auth.
      # Auth expiry must yield 401 (never redirect).
      #
      # NOTE: Auth mechanism itself is intentionally NOT implemented here.
      # Each surface (Core/Sign/etc) already composes the appropriate auth
      # concerns in its own ApplicationController.
    end
  end
end
