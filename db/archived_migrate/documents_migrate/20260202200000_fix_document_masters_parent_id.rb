# frozen_string_literal: true

class FixDocumentMastersParentId < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  DOCUMENT_MASTERS = %w(
    org_document_tag_masters
    org_document_category_masters
    com_document_tag_masters
    com_document_category_masters
    app_document_tag_masters
    app_document_category_masters
  ).freeze

  def up
    safety_assured do
      DOCUMENT_MASTERS.each do |table|
        fix_parent_id_not_null(table)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_parent_id_not_null(table)
    return unless table_exists?(table) && column_exists?(table, :parent_id)

    # Create a root row if none exists
    count = connection.select_value("SELECT COUNT(*) FROM #{table}")
    if Integer(count.to_s, 10) == 0
      # Insert root row with id = 0
      execute("INSERT INTO #{table} (id, code, parent_id) VALUES (0, 'ROOT', 0) ON CONFLICT DO NOTHING")
    end

    # Get the minimum id (root)
    root_id = connection.select_value("SELECT MIN(id) FROM #{table}")
    root_id ||= 0

    # Set all NULL parent_id to root_id
    execute("UPDATE #{table} SET parent_id = #{root_id} WHERE parent_id IS NULL")

    # Set NOT NULL constraint
    execute("ALTER TABLE #{table} ALTER COLUMN parent_id SET NOT NULL")

    Rails.logger.debug { "Fixed #{table}.parent_id NOT NULL" }
  rescue => e
    Rails.logger.debug { "Warning fixing #{table}: #{e.message}" }
  end
end
