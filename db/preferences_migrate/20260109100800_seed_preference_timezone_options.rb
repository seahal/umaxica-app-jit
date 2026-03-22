# frozen_string_literal: true

class SeedPreferenceTimezoneOptions < ActiveRecord::Migration[8.0]
  def up
    timezone_ids = %w(Etc/UTC Asia/Tokyo)

    %w(app com org).each do |namespace|
      safety_assured do
        timezone_ids.each do |tz_id|
          execute(<<~SQL.squish)
            INSERT INTO #{namespace}_preference_timezone_options (id, created_at, updated_at)
            VALUES ('#{tz_id}', NOW(), NOW())
            ON CONFLICT (id) DO NOTHING;
          SQL
        end
      end
    end
  end

  def down
    timezone_ids = %w(Etc/UTC Asia/Tokyo)

    %w(app com org).each do |namespace|
      safety_assured do
        execute(<<~SQL.squish)
          DELETE FROM #{namespace}_preference_timezone_options
          WHERE id IN (#{timezone_ids.map { |id| "'#{id}'" }.join(", ")});
        SQL
      end
    end
  end
end
