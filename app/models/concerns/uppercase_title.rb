# frozen_string_literal: true

module UppercaseTitle
  extend ActiveSupport::Concern

  included do
    before_validation { self.title = title&.upcase }
    validates :title, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/i }
  end
end
