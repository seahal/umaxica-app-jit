class ComTimelineAuditPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
