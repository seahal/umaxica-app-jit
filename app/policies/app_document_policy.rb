# frozen_string_literal: true

# Authorization policy for AppDocument resources
# Implements role-based and ownership-based access control
class AppDocumentPolicy < ApplicationPolicy
  def index?
    # Organization members with any role can view the document list
    can_view?
  end

  def show?
    # Owner or anyone with viewing permissions
    owner? || can_view?
  end

  def create?
    # Contributors and above can create documents
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
        # Admins and Managers see all documents
        scope.all
      elsif actor
        # Other authenticated users see only their own documents
        scope.where(user_id: actor.id)
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end
end
