# frozen_string_literal: true

class AddStepUpVerifiedActivityEvents < ActiveRecord::Migration[8.2]
  USER_EVENT_ID = 28
  STAFF_EVENT_ID = 11

  def up
    safety_assured do
      upsert_event(:user_activity_events, USER_EVENT_ID, "step_up_verified")
      upsert_event(:staff_activity_events, STAFF_EVENT_ID, "step_up_verified")
    end
  end

  def down
    safety_assured do
      execute("DELETE FROM user_activity_events WHERE id = #{USER_EVENT_ID}") if table_exists?(:user_activity_events)
      execute("DELETE FROM staff_activity_events WHERE id = #{STAFF_EVENT_ID}") if table_exists?(:staff_activity_events)
    end
  end

  private

  def upsert_event(table_name, event_id, code)
    return unless table_exists?(table_name)

    attrs = { id: event_id }
    attrs[:name] = code if column_exists?(table_name, :name)
    attrs[:label] = "Step-up verified" if column_exists?(table_name, :label)
    attrs[:description] = "Re-authentication completed and granted for a token-scoped step-up window" if column_exists?(table_name, :description)

    quoted_table = quote_table_name(table_name)
    columns = attrs.keys.map { |key| quote_column_name(key) }
    values = attrs.values.map { |value| quote(value) }
    updates = attrs.except(:id).map { |key, value| "#{quote_column_name(key)} = #{quote(value)}" }
    conflict_action = updates.any? ? "DO UPDATE SET #{updates.join(", ")}" : "DO NOTHING"

    execute <<~SQL.squish
      INSERT INTO #{quoted_table} (#{columns.join(", ")})
      VALUES (#{values.join(", ")})
      ON CONFLICT (id) #{conflict_action}
    SQL
  end
end
