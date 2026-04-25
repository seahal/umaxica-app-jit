# typed: false
# frozen_string_literal: true

class ComTimelineBehaviorPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
