# frozen_string_literal: true

class EnsureNeyoDocumentStatuses < ActiveRecord::Migration[8.2]
  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def insert_status(table, id)
    return unless table_exists?(table)

    cols = [:id]
    vals = [id]

    if column_exists?(table, :active)
      cols << :active
      vals << true
    end

    if column_exists?(table, :position)
      cols << :position
      vals << 0
    end

    if column_exists?(table, :description)
      cols << :description
      vals << id
    end

    if column_exists?(table, :created_at)
      cols << :created_at
      vals << Time.current
    end

    if column_exists?(table, :updated_at)
      cols << :updated_at
      vals << Time.current
    end

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (#{cols.join(", ")})
        VALUES (#{vals.map { |v| connection.quote(v) }.join(", ")})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
