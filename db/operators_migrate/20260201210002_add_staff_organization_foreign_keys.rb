# frozen_string_literal: true

# Migration to add foreign keys for staff, organization, and department associations
# This resolves ForeignKeyChecker warnings for various operator associations
class AddStaffOrganizationForeignKeys < ActiveRecord::Migration[7.1]
  def change
    # StaffOneTimePassword associations
    add_foreign_key :staff_one_time_passwords, :staffs,
                    column: :staff_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true

    add_foreign_key :staff_one_time_passwords, :staff_one_time_password_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_index :staff_one_time_passwords, :status_id,
              name: "index_staff_one_time_passwords_on_status_id",
              if_not_exists: true

    # Organization status
    add_foreign_key :organizations, :organization_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_index :organizations, :status_id,
              name: "index_organizations_on_status_id",
              if_not_exists: true

    # Department associations
    add_foreign_key :departments, :department_statuses,
                    column: :status_id,
                    on_delete: :restrict,
                    validate: false

    add_foreign_key :departments, :workspaces,
                    column: :workspace_id,
                    on_delete: :nullify,
                    validate: false

    add_index :departments, :status_id,
              name: "index_departments_on_status_id",
              if_not_exists: true
    add_index :departments, :workspace_id,
              name: "index_departments_on_workspace_id",
              if_not_exists: true
  end
end
