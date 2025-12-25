module StringPrimaryKey
  extend ActiveSupport::Concern

  included do
    before_create :assign_string_primary_key
  end

  private

    def assign_string_primary_key
      self.id ||= SecureRandom.uuid_v7
    end
end
