# frozen_string_literal: true

module PublicId
  extend ActiveSupport::Concern

  included do
    before_create :generate_public_id
    before_validation :generate_public_id, on: :create
  end

  private

  def generate_public_id
    self.public_id ||= Nanoid.generate(size: 21)
  end
end
