# typed: false
# frozen_string_literal: true

# Shared identity logic for User, Staff, and Customer.
# These are the authenticatable principals that own credentials and sessions.
module Identity
  extend ActiveSupport::Concern

  include ::Accountable
  include ::Withdrawable

  included do
    status_association = :"#{name.underscore}_status"

    validates_reference_table :status_id, association: status_association
    validates_reference_table :visibility_id, association: :visibility
    scope :shreddable, ->(now = Time.current) { where(shreddable_at: ..now) }
  end

  def login_allowed?
    active? && self.class::LOGIN_BLOCKED_STATUS_IDS.exclude?(status_id)
  end
end
