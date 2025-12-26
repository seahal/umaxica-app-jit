# frozen_string_literal: true

module Timeline
  extend ActiveSupport::Concern

  included do
    enum :response_mode, {
      html: "html",
      text: "text",
      pdf: "pdf",
      redirect: "redirect",
    }, suffix: true

    before_validation :ensure_revision_key

    validates :permalink, presence: true, uniqueness: true, length: { maximum: 200 },
                          format: { with: /\A[A-Za-z0-9_]{1,200}\z/ }
    validates :response_mode, presence: true
    validates :revision_key, presence: true
    validates :published_at, presence: true
    validates :expires_at, presence: true
    validates :redirect_url, presence: true, if: :redirect_response_mode?

    validate :published_at_before_expires_at

    scope :available, -> {
      now = Time.current
      where("published_at <= ? AND expires_at > ?", now, now)
    }
  end

  private

  def ensure_revision_key
    self.revision_key ||= SecureRandom.urlsafe_base64(32)
  end

  def published_at_before_expires_at
    return if published_at.blank? || expires_at.blank?
    return if published_at < expires_at

    errors.add(:published_at, "must be before expires_at")
  end
end
