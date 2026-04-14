# frozen_string_literal: true

class AlignDepartmentsWorkspaceWithWorkspaces < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    return unless table_exists?(:departments) && column_exists?(:departments, :workspace_id)

    if foreign_key_exists?(:departments, :organizations, column: :workspace_id)
      remove_foreign_key(:departments, :organizations, column: :workspace_id)
    elsif foreign_key_exists?(:departments, column: :workspace_id)
      remove_foreign_key(:departments, column: :workspace_id)
    end

    return unless table_exists?(:workspaces)

    add_foreign_key(
      :departments, :workspaces,
      column: :workspace_id,
      on_delete: :nullify,
      validate: false,
      if_not_exists: true,
    )

    validate_foreign_key(:departments, :workspaces) if foreign_key_exists?(:departments, :workspaces, column: :workspace_id)
  end

  def down
    return unless table_exists?(:departments) && column_exists?(:departments, :workspace_id)

    if foreign_key_exists?(:departments, :workspaces, column: :workspace_id)
      remove_foreign_key(:departments, :workspaces, column: :workspace_id)
    elsif foreign_key_exists?(:departments, column: :workspace_id)
      remove_foreign_key(:departments, column: :workspace_id)
    end

    return unless table_exists?(:organizations)

    add_foreign_key(
      :departments, :organizations,
      column: :workspace_id,
      on_delete: :nullify,
      validate: false,
      if_not_exists: true,
    )

    validate_foreign_key(:departments, :organizations) if foreign_key_exists?(:departments, :organizations, column: :workspace_id)
  end
end
