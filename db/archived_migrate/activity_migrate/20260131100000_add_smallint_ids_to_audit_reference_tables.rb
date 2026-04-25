# frozen_string_literal: true

class AddSmallintIdsToAuditReferenceTables < ActiveRecord::Migration[8.2]
  REFERENCE_TABLES = %w(
    app_contact_audit_events
    app_document_audit_events
    app_preference_audit_events
    app_timeline_audit_events
    com_contact_audit_events
    com_document_audit_events
    com_preference_audit_events
    com_timeline_audit_events
    org_contact_audit_events
    org_document_audit_events
    org_preference_audit_events
    org_timeline_audit_events
    staff_audit_events
    user_audit_events

    app_contact_audit_levels
    app_document_audit_levels
    app_preference_audit_levels
    app_timeline_audit_levels
    com_contact_audit_levels
    com_document_audit_levels
    com_preference_audit_levels
    com_timeline_audit_levels
    org_contact_audit_levels
    org_document_audit_levels
    org_preference_audit_levels
    org_timeline_audit_levels
    staff_audit_levels
    user_audit_levels
  ).freeze

  def up
    REFERENCE_TABLES.each do |table_name|
      next if column_exists?(table_name, :id_small)

      safety_assured do
        add_column(table_name, :id_small, :integer, limit: 2)
        fill_smallint_ids(table_name)
        change_column_default(table_name, :id_small, from: nil, to: 0)
        change_column_null(table_name, :id_small, false)
        index_name = "index_#{table_name}_on_id_small"
        add_index(table_name, :id_small, unique: true, name: index_name) unless index_exists?(
          table_name, :id_small,
          name: index_name,
        )
      end
    end
  end

  def down
    REFERENCE_TABLES.each do |table_name|
      index_name = "index_#{table_name}_on_id_small"
      remove_index(table_name, name: index_name) if index_exists?(table_name, :id_small, name: index_name)
      remove_column(table_name, :id_small) if column_exists?(table_name, :id_small)
    end
  end

  private

  def fill_smallint_ids(table_name)
    safety_assured do
      execute(<<~SQL.squish)
        WITH mapped AS (
          SELECT id,
                 CASE WHEN id = 'NEYO' THEN 0 ELSE row_number() OVER (ORDER BY id) END AS new_id
          FROM #{table_name}
        )
        UPDATE #{table_name}
        SET id_small = mapped.new_id
        FROM mapped
        WHERE #{table_name}.id = mapped.id
      SQL
    end
  end
end
