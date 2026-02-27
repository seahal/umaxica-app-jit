# frozen_string_literal: true

class EnsureTokenTables < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      enable_extension 'citext' unless extension_enabled?('citext')

      # Staff Token Tables
      ensure_ref_table :staff_token_kinds
      ensure_ref_table :staff_token_statuses

      # Staff Tokens FKs
      add_fk_if_missing :staff_tokens, :staff_token_kinds, :staff_token_kind_id
      add_fk_if_missing :staff_tokens, :staff_token_statuses, :staff_token_status_id
    end
  end

  def down
    # No op
  end

  private

  def ensure_ref_table(table)
    return if table_exists?(table)

    create_table table do |t|
      t.citext :code, null: false
      t.index :code, unique: true
    end

  end

  def add_fk_if_missing(from, to, col)
    return unless table_exists?(from) && table_exists?(to)

    fk_name = "fk_#{from}_on_#{col}"
    result = connection.select_value("SELECT 1 FROM pg_constraint WHERE conname = '#{fk_name}'")
    return if result

    execute "ALTER TABLE #{from} ADD CONSTRAINT #{fk_name} FOREIGN KEY (#{col}) REFERENCES #{to} (id)"

  end
end
