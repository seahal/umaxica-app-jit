module SetId
  extend ActiveSupport::Concern

  included do
    before_create :set_id
  end

  # FIXME: ???
  protected
  def set_id
    self.id = rand(1000000)
  end
end
