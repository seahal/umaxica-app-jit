# frozen_string_literal: true

class AddConsumeOnceFieldsToPreferences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(app_preferences org_preferences com_preferences).freeze

  def up
    TABLES.each do |table|
      add_column table, :used_at, :datetime unless column_exists?(table, :used_at)
      add_column table, :revoked_at, :datetime unless column_exists?(table, :revoked_at)
      add_column table, :compromised_at, :datetime unless column_exists?(table, :compromised_at)
      add_column table, :replaced_by_id, :bigint unless column_exists?(table, :replaced_by_id)

      add_index table, :used_at, algorithm: :concurrently unless index_exists?(table, :used_at)
      add_index table, :revoked_at, algorithm: :concurrently unless index_exists?(table, :revoked_at)
      add_index table, :replaced_by_id, algorithm: :concurrently unless index_exists?(table, :replaced_by_id)
      add_index table, :token_digest, algorithm: :concurrently unless index_exists?(table, :token_digest)

      add_foreign_key table, table, column: :replaced_by_id, validate: false unless foreign_key_exists?(table, table, column: :replaced_by_id)
    end
  end

  def down
    TABLES.each do |table|
      remove_foreign_key table, column: :replaced_by_id if foreign_key_exists?(table, table, column: :replaced_by_id)

      remove_index table, :token_digest, algorithm: :concurrently if index_exists?(table, :token_digest)
      remove_index table, :replaced_by_id, algorithm: :concurrently if index_exists?(table, :replaced_by_id)
      remove_index table, :revoked_at, algorithm: :concurrently if index_exists?(table, :revoked_at)
      remove_index table, :used_at, algorithm: :concurrently if index_exists?(table, :used_at)

      remove_column table, :replaced_by_id if column_exists?(table, :replaced_by_id)
      remove_column table, :compromised_at if column_exists?(table, :compromised_at)
      remove_column table, :revoked_at if column_exists?(table, :revoked_at)
      remove_column table, :used_at if column_exists?(table, :used_at)
    end
  end
end
