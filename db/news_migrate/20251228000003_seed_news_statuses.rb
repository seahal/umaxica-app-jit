# frozen_string_literal: true

class SeedNewsStatuses < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # AppTimelineStatus
      app_statuses = [
        { id: 'ACTIVE' },
        { id: 'DRAFT' },
        { id: 'ARCHIVED' },
        { id: 'NEYO' },
      ]
      upsert_table('app_timeline_statuses', app_statuses)

      # ComTimelineStatus and OrgTimelineStatus
      neyo_statuses = [
        { id: 'ACTIVE' },
        { id: 'DRAFT' },
        { id: 'ARCHIVED' },
        { id: 'NEYO' },
      ]

      upsert_table('com_timeline_statuses', neyo_statuses)
      upsert_table('org_timeline_statuses', neyo_statuses)
    end
  end

  def down
    safety_assured do
      execute "DELETE FROM app_timeline_statuses"
      execute "DELETE FROM com_timeline_statuses"
      execute "DELETE FROM org_timeline_statuses"
    end
  end

  private

  def upsert_table(table_name, rows)
    now = Time.current
    has_created_at = connection.column_exists?(table_name, :created_at)
    has_updated_at = connection.column_exists?(table_name, :updated_at)

    rows.each do |row|
      row[:created_at] ||= now if has_created_at
      row[:updated_at] ||= now if has_updated_at

      cols = row.keys.join(", ")
      vals = row.values.map { |v| connection.quote(v) }.join(", ")

      updates = row.keys.map do |k|
        "#{k} = EXCLUDED.#{k}"
      end.join(", ")

      sql = <<~SQL.squish
        INSERT INTO #{table_name} (#{cols})
        VALUES (#{vals})
        ON CONFLICT (id) DO UPDATE SET #{updates}
      SQL

      execute sql
    end
  end
end
