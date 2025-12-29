# frozen_string_literal: true

class AddNeyoToGuestCategories < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Contact category tables - need NEYO as default category
      %w(
        app_contact_categories
        com_contact_categories
        org_contact_categories
      ).each do |table_name|
        execute <<-SQL.squish
          INSERT INTO #{table_name} (id, created_at, updated_at)
          VALUES ('NEYO', NOW(), NOW())
          ON CONFLICT (id) DO NOTHING;
        SQL
      end
    end
  end

  def down
    safety_assured do
      %w(
        app_contact_categories
        com_contact_categories
        org_contact_categories
      ).each do |table_name|
        execute <<-SQL.squish
          DELETE FROM #{table_name} WHERE id = 'NEYO';
        SQL
      end
    end
  end
end
