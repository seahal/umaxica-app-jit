# frozen_string_literal: true

class AddNeyoToNewsMasterTables < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Category master tables - need NEYO as root parent
      %w(
        app_timeline_category_masters
        com_timeline_category_masters
        org_timeline_category_masters
      ).each do |table_name|
        execute <<-SQL.squish
          INSERT INTO #{table_name} (id, parent_id, created_at, updated_at)
          VALUES ('NEYO', 'NEYO', NOW(), NOW())
          ON CONFLICT (id) DO NOTHING;
        SQL
      end

      # Tag master tables - need NEYO as root parent
      %w(
        app_timeline_tag_masters
        com_timeline_tag_masters
        org_timeline_tag_masters
      ).each do |table_name|
        execute <<-SQL.squish
          INSERT INTO #{table_name} (id, parent_id, created_at, updated_at)
          VALUES ('NEYO', 'NEYO', NOW(), NOW())
          ON CONFLICT (id) DO NOTHING;
        SQL
      end
    end
  end

  def down
    safety_assured do
      %w(
        app_timeline_category_masters
        com_timeline_category_masters
        org_timeline_category_masters
        app_timeline_tag_masters
        com_timeline_tag_masters
        org_timeline_tag_masters
      ).each do |table_name|
        execute <<-SQL.squish
          DELETE FROM #{table_name} WHERE id = 'NEYO';
        SQL
      end
    end
  end
end
