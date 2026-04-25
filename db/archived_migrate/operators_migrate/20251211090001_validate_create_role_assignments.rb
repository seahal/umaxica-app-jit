# frozen_string_literal: true

class ValidateCreateRoleAssignments < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:role_assignments, :staffs)
  end
end
