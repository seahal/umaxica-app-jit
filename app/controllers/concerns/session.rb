module Session
  extend ActiveSupport::Concern

  def reset_flash
    nil
  end
end