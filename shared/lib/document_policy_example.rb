# typed: false
# frozen_string_literal: true

# Example policy demonstrating JWT + DB combined authorization
# This serves as a reference implementation for using Current.token in policies
class DocumentPolicyExample < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Combine JWT domain restriction with DB permissions
      if domain_app? && has_scope?("read:all_documents")
        scope.all
      elsif domain_app? && has_scope?("read:self_documents")
        scope.where(owner_id: actor&.id)
      elsif domain_org? && staff_can_access_documents?
        scope.where(organization_id: current_organization_id)
      else
        scope.none
      end
    end

    private

    def staff_can_access_documents?
      # Check both JWT scope and DB role
      has_scope?("read:org_documents") &&
        actor&.has_role?("viewer", organization: current_organization_id)
    end

    def current_organization_id
      Current.token&.dig("org_id")
    end
  end

  def index?
    # JWT domain check first, then DB role check
    return false unless domain_app? || domain_org?

    has_scope?("read:documents") && (user? || staff_with_access?)
  end

  def show?
    # Can read if: owns it (DB), or has JWT read scope, or is staff with org access
    return true if owner?
    return true if domain_app? && has_scope?("read:documents")
    return true if domain_org? && staff_can_read_org_document?

    false
  end

  def create?
    # JWT write scope required, plus domain/role check
    return false unless has_scope?("write:documents")

    if domain_app?
      user? && actor&.verified?
    elsif domain_org?
      staff_with_write_access?
    else
      false
    end
  end

  def update?
    # Owner can always edit (DB check)
    # Others need JWT scope + appropriate role
    return true if owner?
    return false unless has_scope?("write:documents")

    if domain_org?
      staff_can_edit_document?
    else
      false
    end
  end

  def destroy?
    # Only owners or org admins (combine JWT + DB)
    return true if owner?
    return false unless domain_org? && has_scope?("admin:documents")

    actor&.has_role?("operator", organization: record.organization_id)
  end

  private

  def user?
    actor.is_a?(User)
  end

  def staff_with_access?
    actor.is_a?(Staff) && actor.has_role?("viewer", organization: record.organization_id)
  end

  def staff_with_write_access?
    actor.is_a?(Staff) && actor.has_role?("editor", organization: current_organization_id)
  end

  def staff_can_read_org_document?
    actor.is_a?(Staff) &&
      actor.has_role?("viewer", organization: record.organization_id) &&
      record.organization_id == current_organization_id
  end

  def staff_can_edit_document?
    actor.is_a?(Staff) &&
      actor.has_role?("editor", organization: record.organization_id)
  end

  def current_organization_id
    Current.token&.dig("org_id") || record.organization_id
  end
end
