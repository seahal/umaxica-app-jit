# typed: false
# frozen_string_literal: true

# Concern for flash boundary enforcement across subdomains.
#
# Prevents flash messages from leaking when users navigate between
# different surfaces (app/com/org) and realms (sign/core/apex/docs).
#
# Usage:
#   class ApplicationController < ActionController::Base
#     include ::Session
#     before_action :validate_flash_boundary
#   end
module Session
  extend ActiveSupport::Concern

  FLASH_BOUNDARY_SESSION_KEY = :_flash_boundary

  # Allowed transitions where flash carry-over is intentional.
  # Format: "from_realm:from_surface -> to_realm:to_surface"
  ALLOWED_TRANSITIONS = Set[
    "sign:app -> core:app",
    "sign:com -> core:com",
    "sign:org -> core:org",
    "sign:app -> apex:app",
    "sign:com -> apex:com",
    "sign:org -> apex:org",
  ].freeze

  class_methods do
    def activate_session
      # Session concern provides helper methods but no automatic callbacks
      # Controllers should explicitly use before_action :validate_flash_boundary
    end
  end

  private

  # Call this as a before_action to discard flash on boundary mismatch.
  def validate_flash_boundary
    stored_boundary = session[FLASH_BOUNDARY_SESSION_KEY]

    # No stored boundary means no flash was set from another boundary.
    return if stored_boundary.blank?

    current_boundary = Current.boundary_key

    # Same boundary - flash is valid.
    return if stored_boundary == current_boundary

    # Check allowlist for permitted transitions.
    transition = "#{stored_boundary} -> #{current_boundary}"
    return if ALLOWED_TRANSITIONS.include?(transition)

    # Boundary mismatch - discard flash to prevent leakage.
    flash.discard
    session.delete(FLASH_BOUNDARY_SESSION_KEY)
  end

  # Record the current boundary when flash is written.
  # Call this after setting flash messages, or override flash setters.
  def record_flash_boundary
    session[FLASH_BOUNDARY_SESSION_KEY] = Current.boundary_key
  end

  # Explicitly reset flash and clear the boundary marker.
  def reset_flash
    return unless flash.any?

    flash.discard
    session.delete(FLASH_BOUNDARY_SESSION_KEY)
  end
end
