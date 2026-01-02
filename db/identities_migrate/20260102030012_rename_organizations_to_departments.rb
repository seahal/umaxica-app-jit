# frozen_string_literal: true

class RenameOrganizationsToDepartments < ActiveRecord::Migration[8.2]
  def change
    # Rename organization_statuses table to department_statuses
    safety_assured do
      rename_table :organization_statuses, :department_statuses
    end

    # Rename organizations table to departments
    safety_assured do
      rename_table :organizations, :departments
    end

    # Rename the foreign key column in departments table
    safety_assured do
      rename_column :departments, :organization_status_id, :department_status_id
    end
  end
end
