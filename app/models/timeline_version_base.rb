# frozen_string_literal: true

class TimelineVersionBase < TimelineRecord
  self.abstract_class = true

  validates :permalink, presence: true, format: { with: /\A[A-Za-z0-9_]{1,200}\z/ }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
