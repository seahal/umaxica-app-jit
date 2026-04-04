# typed: false
# frozen_string_literal: true

# Migration to drop behavior tracking tables for contacts
# These tables are being replaced with structured logging via Rails.event
class DropContactBehaviorTables < ActiveRecord::Migration[8.2]
  def up
    # Drop behavior tables from behavior database
    drop_behavior_tables("app")
    drop_behavior_tables("com")
    drop_behavior_tables("org")
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Behavior tables should not be restored. Use structured logging instead."
  end

  private

  def drop_behavior_tables(prefix)
    drop_table(:"#{prefix}_contact_behaviors", if_exists: true)
    drop_table(:"#{prefix}_contact_behavior_events", if_exists: true)
    drop_table(:"#{prefix}_contact_behavior_levels", if_exists: true)
  end
end
