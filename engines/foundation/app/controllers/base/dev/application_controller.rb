# typed: false
# frozen_string_literal: true

# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Dev
        class ApplicationController < ::ApplicationController
          def self.local_prefixes
            super.map { |p| p.sub(%r{\Ajit/foundation/}, "") }
          end

          layout "base/dev/application"
          include ::RateLimit
          include ::Session
          include ::Preference::Regional

          activate_preference_regional
          include ::Authentication::Staff

          activate_staff_authentication
          include ::Authorization::Staff
          include ::Verification::Staff
          include ActionPolicy::Controller
          include ::CurrentSupport
          include ::Finisher

          allow_browser versions: :modern

          # In development/internal tools, we might want different CSRF or host trust rules.
          # For now, we follow staff defaults.
          include ::CsrfTrustedOrigins

          protect_from_forgery using: :header_or_legacy_token,
                               trusted_origins: csrf_trusted_origins(
                                 "FOUNDATION_BASE_DEV_TRUSTED_ORIGINS",
                                 "http://base.dev.localhost,https://base.dev.localhost",
                               ),
                               with: :exception

          before_action :validate_flash_boundary
          before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
          before_action :enforce_access_policy!
          before_action :enforce_verification_if_required
          before_action :set_current
          before_action :set_current_observability
          after_action :purge_current
          after_action :_reset_current_state

          # Require staff authentication for everything in the dev tier
          before_action :authenticate_staff!
          auth_required!

          def preference_class
            ::Preference::ClassRegistry.fetch("Org")[:preference]
          end

          private
        end
      end
    end
  end
end
