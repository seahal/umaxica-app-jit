# typed: false
# frozen_string_literal: true

module SlugId
  extend ActiveSupport::Concern

  included do
    before_create :generate_slug_id
    before_validation :generate_slug_id, on: :create

    validates :slug_id, length: { maximum: 32 }, presence: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  end

  private

  def generate_slug_id
    self.slug_id = Nanoid.generate(size: 32, alphabet: "0123456789abcdefghijklmnopqrstuvwxyz") if slug_id.blank?
  end
end
