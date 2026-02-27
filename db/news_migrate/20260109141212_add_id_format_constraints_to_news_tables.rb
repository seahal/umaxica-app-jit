# frozen_string_literal: true

class AddIdFormatConstraintsToNewsTables < ActiveRecord::Migration[8.2]
  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id::text ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    %w(
      app_timelines
      com_timelines
      org_timelines
      app_timeline_versions
      com_timeline_versions
      org_timeline_versions
      org_timeline_tags
      org_timeline_categories
      app_timeline_tags
      app_timeline_categories
      com_timeline_tags
      com_timeline_categories
    )
  end
end
