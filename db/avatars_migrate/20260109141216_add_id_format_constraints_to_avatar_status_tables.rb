# frozen_string_literal: true

class AddIdFormatConstraintsToAvatarStatusTables < ActiveRecord::Migration[8.2]
  def up
    tables.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

    def tables
      %w[
        post_statuses
        post_review_statuses
        handle_statuses
        handle_assignment_statuses
        avatar_ownership_statuses
        avatar_moniker_statuses
        avatar_membership_statuses
      ]
    end
end
