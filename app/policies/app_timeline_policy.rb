# frozen_string_literal: true

# Authorization policy for AppTimeline resources
# Timeline entries represent chronological events/activities
class AppTimelinePolicy < ApplicationPolicy
  def index?
    # Organization members with any role can view timeline
    can_view?
  end

  def show?
    # Owner or anyone with viewing permissions
    owner? || can_view?
  end

  def create?
    # Contributors and above can create timeline entries
    can_contribute?
  end

  def update?
    # Owner or editors and above can update
    owner? || can_edit?
  end

  def destroy?
    # Owner or managers and above can delete
    owner? || admin_or_manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_or_manager?
        # Admins and Managers see all timeline entries
        scope.all
      elsif actor
        # Other authenticated users see only their own entries
        scope.where(user_id: actor.id)
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
