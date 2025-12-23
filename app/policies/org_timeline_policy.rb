# Authorization policy for OrgTimeline resources (Organization/Staff timeline)
# Internal timeline for staff members only
class OrgTimelinePolicy < ApplicationPolicy
  def index?
    # Only staff members can view org timeline
    actor.is_a?(Staff) && can_view?
  end

  def show?
    # Staff with viewing permissions or entry owner
    actor.is_a?(Staff) && (owner? || can_view?)
  end

  def create?
    # Staff contributors and above can create entries
    actor.is_a?(Staff) && can_contribute?
  end

  def update?
    # Owner or staff editors and above
    actor.is_a?(Staff) && (owner? || can_edit?)
  end

  def destroy?
    # Owner or staff managers and above
    actor.is_a?(Staff) && (owner? || admin_or_manager?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if actor.is_a?(Staff) && admin_or_manager?
        # Staff managers see all entries
        scope.all
      elsif actor.is_a?(Staff)
        # Other staff see their own entries
        scope.where(staff_id: actor.id)
      else
        # Non-staff see nothing
        scope.none
      end
    end
  end
end
