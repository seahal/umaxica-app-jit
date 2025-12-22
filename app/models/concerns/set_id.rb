module SetId
  extend ActiveSupport::Concern

  included do
    before_create :generate_id
  end

  private

    # Generates a UUID v7 for the record before creation.
    # UUID v7 is time-ordered and includes timestamp information for better database performance.
    def generate_id
      self.id = SecureRandom.uuid_v7
    end
end
