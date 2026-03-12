# typed: false
# frozen_string_literal: true

module TokenDeletableSync
  extend ActiveSupport::Concern

  included do
    before_validation :sync_deletable_at_from_expiry
    scope :deletable, ->(now = Time.current) { where(deletable_at: ..now) }
  end

  private

  def sync_deletable_at_from_expiry
    return unless has_attribute?(:deletable_at)

    self.deletable_at = derived_deletable_at
  end

  def expiry_attribute_name
    return :expires_at if has_attribute?(:expires_at)
    return :refresh_expires_at if has_attribute?(:refresh_expires_at)

    raise "#{self.class.name} does not have an expires_at-style attribute"
  end

  def derived_deletable_at
    if has_attribute?(:revoked_at) && revoked_at.present?
      revoked_at + 1.day
    else
      public_send(expiry_attribute_name)
    end
  end
end
