class OrgTimelineAuditPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
