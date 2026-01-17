# frozen_string_literal: true

class SeedUserTokenStatuses < ActiveRecord::Migration[8.2]
  STATUS_IDS = %w(NEYO).freeze

  def up
    return unless table_exists?(:user_token_statuses)

    STATUS_IDS.each do |status_id|
      safety_assured do
        execute <<~SQL.squish
          INSERT INTO user_token_statuses (id)
          VALUES ('#{status_id}')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def down
    # No-op: keep seeded reference data in place.
  end
end
