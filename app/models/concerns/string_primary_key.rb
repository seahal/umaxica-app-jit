# frozen_string_literal: true

module StringPrimaryKey
  extend ActiveSupport::Concern

  included do
    before_validation :assign_string_primary_key, on: :create

    if name.match?(/(Status|Event|Level|Category)\z/)
      validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
    else
      validates :id, format: { with: /\A[a-zA-Z0-9_-]+\z/ }
    end
  end

  private

  def assign_string_primary_key
    self.id ||= SecureRandom.uuid_v7
  end
end
