# frozen_string_literal: true

class EnsureOccurrenceStatuses < ActiveRecord::Migration[8.2]
  STATUS_IDS = %w(NEYO ACTIVE INACTIVE BLOCKED).freeze
  TABLES = %w(
    area_occurrence_statuses
    domain_occurrence_statuses
    email_occurrence_statuses
    ip_occurrence_statuses
    telephone_occurrence_statuses
    zip_occurrence_statuses
    staff_occurrence_statuses
    user_occurrence_statuses
  ).freeze

  def up
    TABLES.each do |table|
      next unless table_exists?(table)

      STATUS_IDS.each do |id|
        safety_assured do
          execute <<~SQL.squish
            INSERT INTO #{table} (id)
            VALUES ('#{id}')
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end
    end
  end

  def down
    # No-op to avoid removing shared reference data.
  end
end
