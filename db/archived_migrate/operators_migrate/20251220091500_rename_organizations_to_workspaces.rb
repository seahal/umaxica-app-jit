# frozen_string_literal: true

class RenameOrganizationsToWorkspaces < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      rename_table(:organizations, :workspaces)
    end
  end

  def down
    safety_assured do
      rename_table(:workspaces, :organizations)
    end
  end
end
