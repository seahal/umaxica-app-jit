# typed: false
# frozen_string_literal: true

module StringPrimaryKey
  extend ActiveSupport::Concern

  included do
    validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
    before_validation :normalize_string_primary_key
  end

  private

  def normalize_string_primary_key
    self.id = id.to_s.upcase if id.present?
  end
end
