# frozen_string_literal: true

module Occurrence
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_expires_at
    before_validation :ensure_expires_at
    validates :public_id,
              presence: true,
              length: { is: 21 },
              format: { with: /\A[A-Za-z0-9_-]{21}\z/ },
              uniqueness: true
    validates :body, presence: true, uniqueness: true
    validates :status_id, presence: true
    validates :memo, length: { maximum: 1024 }, allow_nil: true
  end

  private

  def set_default_expires_at
    self.expires_at ||= 7.years.from_now if has_attribute?(:expires_at)
  end

  def ensure_expires_at
    self.expires_at ||= 7.years.from_now
  end
end
