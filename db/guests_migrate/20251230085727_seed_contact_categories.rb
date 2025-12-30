# frozen_string_literal: true

class SeedContactCategories < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Seed com_contact_categories (uses empty string for root parent_id)
      upsert_categories(
        "com_contact_categories", [
          { id: "SECURITY_ISSUE", parent_id: "", position: 0 },
          { id: "OTHERS", parent_id: "", position: 1 },
        ],
      )

      # Seed app_contact_categories (uses NIL_UUID for root parent_id)
      upsert_categories(
        "app_contact_categories", [
          { id: "APPLICATION_INQUIRY", parent_id: "00000000-0000-0000-0000-000000000000", position: 0 },
          { id: "APPLICATION_SUPPORT", parent_id: "00000000-0000-0000-0000-000000000000", position: 1 },
          { id: "APPLICATION_FEEDBACK", parent_id: "00000000-0000-0000-0000-000000000000", position: 2 },
        ],
      )

      # Seed org_contact_categories (uses empty string for root parent_id)
      upsert_categories(
        "org_contact_categories", [
          { id: "ORGANIZATION_INQUIRY", parent_id: "", position: 0 },
          { id: "ORGANIZATION_PARTNERSHIP", parent_id: "", position: 1 },
          { id: "ORGANIZATION_FEEDBACK", parent_id: "", position: 2 },
        ],
      )
    end
  end

  def down
    # No-op to preserve reference data
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
