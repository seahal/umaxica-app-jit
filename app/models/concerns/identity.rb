# typed: false
# frozen_string_literal: true

# Shared identity logic for User and Staff.
# These are the authenticatable principals that own credentials and sessions.
module Identity
  extend ActiveSupport::Concern

  include ::Accountably
  include ::Withdrawable

  included do
    validates :status_id, numericality: { only_integer: true }
    scope :shreddable, ->(now = Time.current) { where(shreddable_at: ..now) }
  end

  def login_allowed?
    active? && self.class::LOGIN_BLOCKED_STATUS_IDS.exclude?(status_id)
  end
end
