# frozen_string_literal: true

module UppercaseId
  extend ActiveSupport::Concern

  included do
    before_validation { self.id = id&.upcase }
    validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/i }
  end
end
