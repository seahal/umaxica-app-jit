# frozen_string_literal: true

module UuidV7PrimaryKey
  extend ActiveSupport::Concern

  included do
    before_validation :assign_uuid_v7_primary_key, on: :create
    validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
  end

  private

    def assign_uuid_v7_primary_key
      self.id ||= SecureRandom.uuid_v7
    end
end
