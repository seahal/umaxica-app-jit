# frozen_string_literal: true

class AddLowerCodeUniqueIndexesNews < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %w(
    app_timeline_category_masters
    app_timeline_statuses
    app_timeline_tag_masters
    com_timeline_category_masters
    com_timeline_statuses
    com_timeline_tag_masters
    org_timeline_category_masters
    org_timeline_statuses
    org_timeline_tag_masters
  ).freeze

  def up
    safety_assured do
      TABLES.each do |table|
        add_lower_code_index(table)
      end
    end
  end

  def down
    TABLES.each do |table|
      index_name = "index_#{table}_on_lower_code"
      remove_index table, name: index_name if index_exists?(table, nil, name: index_name)
    end
  end

  private

  def add_lower_code_index(table)
    return unless table_exists?(table) && column_exists?(table, :code)

    index_name = "index_#{table}_on_lower_code"
    return if index_exists?(table, nil, name: index_name)

    add_index table, "lower(code)", unique: true, name: index_name, algorithm: :concurrently
  end
end
