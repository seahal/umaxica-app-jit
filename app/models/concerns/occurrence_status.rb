# frozen_string_literal: true

module OccurrenceStatus
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_expires_at
    before_validation :ensure_expires_at
  end

  private

  def set_default_expires_at
    self.expires_at ||= 7.years.from_now if has_attribute?(:expires_at)
  end

  def ensure_expires_at
    self.expires_at ||= 7.years.from_now
  end
end
