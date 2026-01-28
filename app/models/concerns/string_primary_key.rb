# frozen_string_literal: true

module StringPrimaryKey
  extend ActiveSupport::Concern

  included do
    before_validation { self.id = id&.upcase }
    validates :id, presence: true, length: { maximum: 255 }, uniqueness: true, format: { with: /\A[A-Z0-9_]+\z/ }
  end
end
