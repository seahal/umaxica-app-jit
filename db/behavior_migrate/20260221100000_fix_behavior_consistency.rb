# frozen_string_literal: true

class FixBehaviorConsistency < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  BEHAVIOR_PREFIXES = %w(
    app_timeline com_timeline org_timeline
    app_document com_document org_document
    app_contact com_contact org_contact
  ).freeze

  def up
    safety_assured do
      BEHAVIOR_PREFIXES.each do |prefix|
        ensure_reference_row("#{prefix}_behavior_events", 1)
        ensure_reference_row("#{prefix}_behavior_levels", 1)
      end

      BEHAVIOR_PREFIXES.each do |prefix|
        table = "#{prefix}_behaviors"
        next unless table_exists?(table)

        execute("UPDATE #{table} SET event_id = 1 WHERE event_id IS NULL")
        execute("UPDATE #{table} SET level_id = 1 WHERE level_id IS NULL")

        change_column_null(table, :event_id, false) if column_allows_null?(table, :event_id)
        change_column_null(table, :level_id, false) if column_allows_null?(table, :level_id)

        add_index(table, :subject_id, algorithm: :concurrently) unless index_exists?(table, :subject_id)

        add_foreign_key(table, "#{prefix}_behavior_events", column: :event_id) unless foreign_key_exists?(table, "#{prefix}_behavior_events", column: :event_id)
        add_foreign_key(table, "#{prefix}_behavior_levels", column: :level_id) unless foreign_key_exists?(table, "#{prefix}_behavior_levels", column: :level_id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def ensure_reference_row(table, id)
    return unless table_exists?(table)

    quoted_table = connection.quote_table_name(table)
    execute("INSERT INTO #{quoted_table} (id) VALUES (#{Integer(id)}) ON CONFLICT (id) DO NOTHING")
  end

  def column_allows_null?(table, column)
    connection.columns(table).find { |c| c.name == column.to_s }&.null
  end
end
