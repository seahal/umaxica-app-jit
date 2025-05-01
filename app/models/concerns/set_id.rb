module SetId
  extend ActiveSupport::Concern

  included do
    before_create :generate_id
  end

  private

  # FIXME: ???
  def generate_id
    self.id = SecureRandom.uuid_v7
  end
end
