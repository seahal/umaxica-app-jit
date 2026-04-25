# frozen_string_literal: true

class AddOrganizationToRoles < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column(:roles, :organization_id, :bigint)
    add_index(:roles, :organization_id, algorithm: :concurrently)
    # add_foreign_key :roles, :organizations # Cross-db FK not supported
    safety_assured do
      change_column_null(:roles, :organization_id, false)
    end
  end
end
