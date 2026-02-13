# frozen_string_literal: true

class OrgTimelineBehaviorPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
