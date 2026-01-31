# frozen_string_literal: true

class ConvertAuditChildFkColumnsToSmallint < ActiveRecord::Migration[8.2]
  CHILD_COLUMNS = {
    app_contact_histories: {
      event_id: :app_contact_audit_events,
      level_id: :app_contact_audit_levels,
    },
    app_document_audits: {
      event_id: :app_document_audit_events,
      level_id: :app_document_audit_levels,
    },
    app_preference_audits: {
      event_id: :app_preference_audit_events,
      level_id: :app_preference_audit_levels,
    },
    app_timeline_audits: {
      event_id: :app_timeline_audit_events,
      level_id: :app_timeline_audit_levels,
    },
    com_contact_audits: {
      event_id: :com_contact_audit_events,
      level_id: :com_contact_audit_levels,
    },
    com_document_audits: {
      event_id: :com_document_audit_events,
      level_id: :com_document_audit_levels,
    },
    com_preference_audits: {
      event_id: :com_preference_audit_events,
      level_id: :com_preference_audit_levels,
    },
    com_timeline_audits: {
      event_id: :com_timeline_audit_events,
      level_id: :com_timeline_audit_levels,
    },
    org_contact_histories: {
      event_id: :org_contact_audit_events,
      level_id: :org_contact_audit_levels,
    },
    org_document_audits: {
      event_id: :org_document_audit_events,
      level_id: :org_document_audit_levels,
    },
    org_preference_audits: {
      event_id: :org_preference_audit_events,
      level_id: :org_preference_audit_levels,
    },
    org_timeline_audits: {
      event_id: :org_timeline_audit_events,
      level_id: :org_timeline_audit_levels,
    },
    staff_audits: {
      event_id: :staff_audit_events,
      level_id: :staff_audit_levels,
    },
    user_audits: {
      event_id: :user_audit_events,
      level_id: :user_audit_levels,
    },
  }.freeze

  def up
    CHILD_COLUMNS.each do |table_name, columns|
      columns.each do |column_name, parent_table|
        safety_assured do
          drop_foreign_key_if_exists(table_name, column: column_name)
          remove_index table_name, column: column_name if index_exists?(table_name, column: column_name)

          small_column = "#{column_name}_small"
          next if column_exists?(table_name, small_column)

          add_column table_name, small_column, :integer, limit: 2
          seed_child_small_column(table_name, column_name, parent_table, small_column)
          change_column_default table_name, small_column, from: nil, to: 0
          change_column_null table_name, small_column, false

          remove_column table_name, column_name
          rename_column table_name, small_column, column_name

          add_index table_name, column_name, name: "index_#{table_name}_on_#{column_name}" unless index_exists?(table_name, column_name)
          add_check_constraint table_name, "#{column_name} >= 0", name: "#{table_name}_#{column_name}_non_negative_check"
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_foreign_key_if_exists(table_name, options)
    remove_foreign_key table_name, **options if foreign_key_exists?(table_name, **options)
  end

  def seed_child_small_column(table_name, column_name, parent_table, small_column_name)
    column = column_name
    execute <<~SQL.squish
      UPDATE #{table_name}
      SET #{small_column_name} = COALESCE(parent_table.id_small, 0)
      FROM #{parent_table} AS parent_table
      WHERE #{table_name}.#{column} = parent_table.id
    SQL

    execute <<~SQL.squish
      UPDATE #{table_name}
      SET #{small_column_name} = 0
      WHERE #{small_column_name} IS NULL
    SQL
  end
end
