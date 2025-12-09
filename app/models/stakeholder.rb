module Stakeholder
  def staff?
    raise NotImplementedError, "#{self.class} must implement staff? method"
  end

  def user?
    raise NotImplementedError, "#{self.class} must implement user? method"
  end
end
