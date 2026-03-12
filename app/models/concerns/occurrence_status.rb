# typed: false
# frozen_string_literal: true

module OccurrenceStatus
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_lifecycle_timestamps
    before_validation :ensure_lifecycle_timestamps
  end

  private

  def set_default_lifecycle_timestamps
    self.revoked_at ||= Float::INFINITY if has_attribute?(:revoked_at)
    self.deletable_at ||= Float::INFINITY if has_attribute?(:deletable_at)
  end

  def ensure_lifecycle_timestamps
    self.revoked_at ||= Float::INFINITY if has_attribute?(:revoked_at)
    self.deletable_at ||= Float::INFINITY if has_attribute?(:deletable_at)
  end
end
