# Role-based authorization helpers for User and Staff models
module HasRoles
  extend ActiveSupport::Concern

  included do
    has_many :role_assignments, dependent: :destroy
    has_many :roles, through: :role_assignments
  end

  # Check if actor has a specific role
  # @param role_key [String] The role key (e.g., 'admin', 'manager')
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def has_role?(role_key, organization: nil)
    query = roles.where(key: role_key)
    query = query.where(organization: organization) if organization
    query.exists?
  end

  # Check if actor has any of the specified roles
  # @param role_keys [Array<String>] Role keys to check
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def has_any_role?(*role_keys, organization: nil)
    role_keys.any? { |key| has_role?(key, organization: organization) }
  end

  # Get all roles within a specific organization
  # @param organization [Organization] The organization
  # @return [ActiveRecord::Relation<Role>]
  def roles_in(organization)
    roles.where(organization: organization)
  end

  # Check if actor has admin or manager role
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def admin_or_manager?(organization: nil)
    has_any_role?("admin", "manager", organization: organization)
  end

  # Check if actor has editing permissions (admin, manager, or editor)
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_edit?(organization: nil)
    has_any_role?("admin", "manager", "editor", organization: organization)
  end

  # Check if actor has viewing permissions (any role)
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_view?(organization: nil)
    has_any_role?("admin", "manager", "editor", "contributor", "viewer", organization: organization)
  end

  # Check if actor can contribute (create content)
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_contribute?(organization: nil)
    has_any_role?("admin", "manager", "editor", "contributor", organization: organization)
  end
end
