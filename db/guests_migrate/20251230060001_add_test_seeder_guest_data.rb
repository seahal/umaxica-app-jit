# frozen_string_literal: true

class AddTestSeederGuestData < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!
  STATUS_IDS = %w(UNVERIFIED VERIFIED ACTIVE OTHERS SECURITY_ISSUE).freeze

  def up
    safety_assured do
      # Insert missing statuses and categories needed by TestSeeder
      %w(app com org).each do |prefix|
        # Insert statuses
        status_table = "#{prefix}_contact_statuses"
        if table_exists?(status_table)
          STATUS_IDS.each do |id|
            cols = []
            vals = []

            cols << "id"
            vals << connection.quote(id)

            if column_exists?(status_table, :active)
              cols << "active"
              vals << "TRUE"
            end

            if column_exists?(status_table, :position)
              cols << "position"
              vals << "0"
            end

            if column_exists?(status_table, :created_at)
              cols << "created_at"
              vals << "CURRENT_TIMESTAMP"
            end

            if column_exists?(status_table, :updated_at)
              cols << "updated_at"
              vals << "CURRENT_TIMESTAMP"
            end

            execute <<~SQL.squish
              INSERT INTO #{status_table} (#{cols.join(", ")})
              VALUES (#{vals.join(", ")})
              ON CONFLICT (id) DO NOTHING
            SQL
          end
        end

        # Insert categories
        category_table = "#{prefix}_contact_categories"
        if table_exists?(category_table)
          STATUS_IDS.each do |id|
            cols = []
            vals = []

            cols << "id"
            vals << connection.quote(id)

            if column_exists?(category_table, :active)
              cols << "active"
              vals << "TRUE"
            end

            if column_exists?(category_table, :position)
              cols << "position"
              vals << "0"
            end

            if column_exists?(category_table, :created_at)
              cols << "created_at"
              vals << "CURRENT_TIMESTAMP"
            end

            if column_exists?(category_table, :updated_at)
              cols << "updated_at"
              vals << "CURRENT_TIMESTAMP"
            end

            execute <<~SQL.squish
              INSERT INTO #{category_table} (#{cols.join(", ")})
              VALUES (#{vals.join(", ")})
              ON CONFLICT (id) DO NOTHING
            SQL
          end
        end
      end
    end
  end

  def down
    # No-op - we don't want to delete reference data
  end
end
