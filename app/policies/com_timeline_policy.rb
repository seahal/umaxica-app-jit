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
      if actor.is_a?(Staff)
        # Staff see all entries
        scope.all
      elsif actor.is_a?(User)
        # Users see available timeline entries only
        scope.available
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
