# frozen_string_literal: true

# Base policy class for authorization using Pundit
# Provides common authorization patterns for both User and Staff actors
class ApplicationPolicy
  attr_reader :actor, :record  # Use 'actor' instead of 'user' to support both User and Staff

  # Alias user to actor for compatibility with standard Pundit expectations and tests
  alias_method :user, :actor

  def initialize(actor, record)
    @actor = actor
    @record = record
  end

  # Default permissions - deny all by default (whitelist approach)
  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  # Get the workspace from the record if it has one
  # @return [Workspace, nil]
  def organization
    @organization ||= if record.respond_to?(:organization)
      record.organization
    elsif record.respond_to?(:organization_id) && record.organization_id.present?
      Workspace.find_by(id: record.organization_id)
    end
  end

  # Check if actor owns the record
  # @return [Boolean]
  def owner?
    return false unless actor

    if actor.is_a?(User) && record.respond_to?(:user_id)
      record.user_id == actor.id
    elsif actor.is_a?(Staff) && record.respond_to?(:staff_id)
      record.staff_id == actor.id
    else
      false
    end
  end

  # Role-based checks
  def admin?
    actor&.has_role?("admin", organization: organization)
  end

  def manager?
    actor&.has_role?("manager", organization: organization)
  end

  def editor?
    actor&.has_role?("editor", organization: organization)
  end

  def contributor?
    actor&.has_role?("contributor", organization: organization)
  end

  def viewer?
    actor&.has_role?("viewer", organization: organization)
  end

  # Combined role checks
  def admin_or_manager?
    actor&.admin_or_manager?(organization: organization)
  end

  def can_edit?
    actor&.can_edit?(organization: organization)
  end

  def can_view?
    actor&.can_view?(organization: organization)
  end

  def can_contribute?
    actor&.can_contribute?(organization: organization)
  end

  # Scope class for filtering collections based on permissions
  class Scope
    attr_reader :actor, :scope

    def initialize(actor, scope)
      @actor = actor
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    protected

    # Helper to check if actor has a role
    def has_role?(role_key, organization: nil)
      actor&.has_role?(role_key, organization: organization)
    end

    def admin_or_manager?(organization: nil)
      actor&.admin_or_manager?(organization: organization)
    end
  end
end
