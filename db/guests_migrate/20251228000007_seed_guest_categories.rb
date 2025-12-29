# frozen_string_literal: true

class SeedGuestCategories < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      upsert_table(
        "app_contact_categories", [
          { id: "NEYO", description: "None/Default category" },
          { id: "APPLICATION_INQUIRY", description: "Application inquiry category" },
          { id: "APPLICATION_SUPPORT", description: "Application support category" },
          { id: "APPLICATION_FEEDBACK", description: "Application feedback category" },
        ],
      )

      upsert_table(
        "com_contact_categories", [
          { id: "SECURITY_ISSUE", description: "ROOT" },
          { id: "OTHERS", description: "Miscellaneous inquiries" },
          { id: "NEYO", description: "NONE" },
        ],
      )

      upsert_table(
        "org_contact_categories", [
          { id: "NEYO", description: "None/Default category" },
          { id: "ORGANIZATION_INQUIRY", description: "Organization inquiry category" },
          { id: "ORGANIZATION_PARTNERSHIP", description: "Organization partnership category" },
          { id: "ORGANIZATION_FEEDBACK", description: "Organization feedback category" },
        ],
      )
    end
  end

  def down
    # No-op
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
