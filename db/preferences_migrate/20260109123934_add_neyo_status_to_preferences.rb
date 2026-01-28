# frozen_string_literal: true

class AddNeyoStatusToPreferences < ActiveRecord::Migration[8.2]
  def up
    %w[app org com].each do |prefix|
      table_name = "#{prefix}_preference_statuses"
      safety_assured do
        execute "INSERT INTO #{table_name} (id, created_at, updated_at) VALUES ('NEYO', NOW(), NOW()) ON CONFLICT (id) DO NOTHING"
      end
    end
  end

  def down
    %w[app org com].each do |prefix|
      table_name = "#{prefix}_preference_statuses"
      safety_assured do
        execute "DELETE FROM #{table_name} WHERE id = 'NEYO'"
      end
    end
  end
end
