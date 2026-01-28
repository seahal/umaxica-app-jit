# frozen_string_literal: true

class SeedUserPasskeyStatuses < ActiveRecord::Migration[8.2]
  STATUSES = %w[NEYO ACTIVE DISABLED DELETED REVOKED].freeze

  def up
    return unless table_exists?(:user_passkey_statuses)

    STATUSES.each do |status_id|
      insert_status_if_missing(status_id)
    end
  end

  def down
    # No-op so shared reference data is not removed when rolling back.
  end

  private

    def insert_status_if_missing(status_id)
      quoted_status = connection.quote(status_id)
      connection.execute <<~SQL.squish
        INSERT INTO user_passkey_statuses (id)
        VALUES (#{quoted_status})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
end
