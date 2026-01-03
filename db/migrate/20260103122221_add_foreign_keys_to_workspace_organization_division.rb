# frozen_string_literal: true

class AddForeignKeysToWorkspaceOrganizationDivision < ActiveRecord::Migration[8.2]
  def change
    # Add foreign keys for Workspace
    add_foreign_key :workspaces, :workspace_statuses,
                    column: :workspace_status_id,
                    primary_key: :id,
                    on_delete: :restrict,
                    if_not_exists: true

    # Add index for departments.workspace_id (if not exists, for FK performance)
    add_index :departments, :workspace_id, if_not_exists: true

    # Add foreign keys for Organization
    add_foreign_key :organizations, :organization_statuses,
                    column: :organization_status_id,
                    primary_key: :id,
                    on_delete: :restrict,
                    if_not_exists: true

    # Add foreign keys for Division
    add_foreign_key :divisions, :organizations,
                    on_delete: :restrict,
                    if_not_exists: true

    # Add foreign key from clients to divisions with nullify
    add_foreign_key :clients, :divisions,
                    on_delete: :nullify,
                    if_not_exists: true

    # Add foreign key from admins to departments with nullify
    add_foreign_key :admins, :departments,
                    on_delete: :nullify,
                    if_not_exists: true
  end
end
