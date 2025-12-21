# frozen_string_literal: true

# Authorization policy for User resource management
# Controls who can view, create, update, and delete users
class UserPolicy < ApplicationPolicy
  def index?
    # Only staff managers and above can view user list
    actor.is_a?(Staff) && admin_or_manager?
  end

  def show?
    # Users can see their own profile, staff managers can see any user
    owner? || (actor.is_a?(Staff) && admin_or_manager?)
  end

  def create?
    # Public registration is handled separately
    # Only staff admins can directly create users
    actor.is_a?(Staff) && admin?
  end

  def update?
    # Users can update their own profile, staff managers can update any user
    owner? || (actor.is_a?(Staff) && admin_or_manager?)
  end

  def destroy?
    # Only staff admins can delete users (or users can delete themselves via withdrawal)
    (owner? && actor.is_a?(User)) || (actor.is_a?(Staff) && admin?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if actor.is_a?(Staff) && admin_or_manager?
        # Staff managers see all users
        scope.all
      elsif actor.is_a?(User)
        # Users see only themselves
        scope.where(id: actor.id)
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
