# frozen_string_literal: true

module Occurrence
  extend ActiveSupport::Concern

  included do
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
end
