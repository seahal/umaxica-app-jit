# typed: false
# frozen_string_literal: true

module Occurrence
  extend ActiveSupport::Concern

  DEFAULT_LIFECYCLE_AT = Float::INFINITY

  included do
    after_initialize :set_default_lifecycle_timestamps
    before_validation :ensure_lifecycle_timestamps
    validates :public_id,
              length: { is: 21 },
              format: { with: /\A[A-Za-z0-9_-]{21}\z/ },
              uniqueness: true
    validates :body, presence: true, uniqueness: true
    validates :status_id, presence: true
    validates :memo, length: { maximum: 1024 }, allow_nil: true
  end

  private

  def set_default_lifecycle_timestamps
    self.revoked_at ||= DEFAULT_LIFECYCLE_AT if has_attribute?(:revoked_at)
    self.deletable_at ||= DEFAULT_LIFECYCLE_AT if has_attribute?(:deletable_at)
  end

  def ensure_lifecycle_timestamps
    self.revoked_at ||= DEFAULT_LIFECYCLE_AT if has_attribute?(:revoked_at)
    self.deletable_at ||= DEFAULT_LIFECYCLE_AT if has_attribute?(:deletable_at)
  end
end
