# frozen_string_literal: true

class SeedContactCategories < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def upsert_categories(table_name, categories)
    now = Time.current

    categories.each do |category|
      category[:created_at] ||= now
      category[:updated_at] ||= now

      cols = category.keys.join(", ")
      vals = category.values.map { |v| connection.quote(v) }.join(", ")

      updates = category.keys.map do |k|
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
