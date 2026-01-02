# frozen_string_literal: true

class ValidateOrganizationsTreeForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :organizations, :organizations, column: :parent_id
    validate_foreign_key :organizations, :organization_statuses, column: :organization_status_id
  end
end
