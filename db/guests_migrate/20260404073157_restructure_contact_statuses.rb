# typed: false
# frozen_string_literal: true

# Migration to restructure contact status values
# - 0 = NOTHING (initial state)
# - 1 = COMPLETED (success)
# - 2+ = error/non-normal states (SPAM, FAILED, etc.)
class RestructureContactStatuses < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # First, update existing records to use new status values
      # Current mapping to new mapping:
      # 1 (NOTHING) -> 0 (NOTHING)
      # 5 (COMPLETED) or 10 (COMPLETED_CONTACT_ACTION) -> 1 (COMPLETED)
      # Others -> 2 (FAILED) for now, to be reviewed manually

      %w[app_contacts com_contacts org_contacts].each do |table|
        execute("UPDATE #{table} SET status_id = 0 WHERE status_id = 1") # NOTHING
        execute("UPDATE #{table} SET status_id = 1 WHERE status_id IN (5, 10)") # COMPLETED variants
        execute("UPDATE #{table} SET status_id = 2 WHERE status_id NOT IN (0, 1)") # Others -> FAILED
      end

      # Update status reference tables
      restructure_status_table(:app_contact_statuses)
      restructure_status_table(:com_contact_statuses)
      restructure_status_table(:org_contact_statuses)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Status restructuring cannot be reversed automatically."
  end

  private

  def restructure_status_table(table)
    # Delete old statuses and insert new ones
    execute("DELETE FROM #{table}")

    execute(<<~SQL)
      INSERT INTO #{table} (id) VALUES
        (0),  -- NOTHING
        (1),  -- COMPLETED
        (2),  -- FAILED
        (3),  -- SPAM_DETECTED
        (4),  -- PENDING_REVIEW
        (5),  -- RESERVED for future use
        (6),  -- RESERVED for future use
        (7),  -- RESERVED for future use
        (8),  -- RESERVED for future use
        (9)   -- RESERVED for future use
    SQL
  end
end
