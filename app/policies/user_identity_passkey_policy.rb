# frozen_string_literal: true

class UserIdentityPasskeyPolicy < ApplicationPolicy
  def index?
    actor.present?
  end

  def show?
    owner?
  end

  def create?
    actor.present?
  end

  def new?
    create?
  end

  def update?
    owner?
  end

  def edit?
    update?
  end

  def destroy?
    owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless actor

      scope.where(user_id: actor.id)
    end
  end
end
