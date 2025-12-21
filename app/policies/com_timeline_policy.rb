# frozen_string_literal: true

# Authorization policy for ComTimeline resources (Corporate timeline)
# Staff members manage corporate timeline entries
class ComTimelinePolicy < ApplicationPolicy
  def index?
    # Staff with viewing permissions or users can see timeline
    (actor.is_a?(Staff) && can_view?) || actor.is_a?(User)
  end

  def show?
    # Staff with viewing permissions or entry owner
    (actor.is_a?(Staff) && can_view?) || owner?
  end

  def create?
    # Only staff contributors and above can create corporate timeline entries
    actor.is_a?(Staff) && can_contribute?
  end

  def update?
    # Staff editors and above or owner
    actor.is_a?(Staff) && (owner? || can_edit?)
  end

  def destroy?
    # Only staff managers and above can delete
    actor.is_a?(Staff) && admin_or_manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if actor.is_a?(Staff) && admin_or_manager?
        # Staff managers see all entries
        scope.all
      elsif actor.is_a?(Staff)
        # Other staff see their own entries
        scope.where(staff_id: actor.id)
      elsif actor.is_a?(User)
        # Users see published timeline entries only
        # TODO: Add proper status filtering when publishing workflow is implemented
        scope.where.not(com_timeline_status_id: "DRAFT")
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
