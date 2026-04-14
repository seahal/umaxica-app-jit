# frozen_string_literal: true

class CreateNotificationActivityTables < ActiveRecord::Migration[8.1]
  def change
    create_table(:notification_activity_events) do |t|
    end

    create_table(:notification_activity_levels) do |t|
    end

    create_table(:notification_activities) do |t|
      t.bigint("actor_id", default: 0, null: false)
      t.text("actor_type", default: "", null: false)
      t.jsonb("context", default: {}, null: false)
      t.datetime("created_at", null: false)
      t.text("current_value", default: "", null: false)
      t.bigint("event_id", default: 0, null: false)
      t.datetime("expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false)
      t.inet("ip_address", default: "0.0.0.0", null: false)
      t.bigint("level_id", default: 0, null: false)
      t.datetime("occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false)
      t.text("previous_value", default: "", null: false)
      t.bigint("subject_id", null: false)
      t.text("subject_type", null: false)
      t.datetime("updated_at", null: false)

      t.index(
        ["actor_id", "occurred_at"],
        name: "index_notification_activities_on_actor_id_and_occurred_at",
      )
      t.index(["event_id"], name: "index_notification_activities_on_event_id")
      t.index(["expires_at"], name: "index_notification_activities_on_expires_at")
      t.index(["level_id"], name: "index_notification_activities_on_level_id")
      t.index(["occurred_at"], name: "index_notification_activities_on_occurred_at")
      t.index(
        %w(subject_type subject_id occurred_at),
        name: "idx_on_subject_type_subject_id_occurred_at_notification_act",
      )
    end

    add_foreign_key(
      "notification_activities", "notification_activity_events",
      column: "event_id", validate: false,
    )
    add_foreign_key(
      "notification_activities", "notification_activity_levels",
      column: "level_id", validate: false,
    )

    add_check_constraint(
      "notification_activities", "event_id >= 0",
      name: "notification_activities_event_id_non_negative_check",
    )
    add_check_constraint(
      "notification_activities", "level_id >= 0",
      name: "notification_activities_level_id_non_negative_check",
    )
  end
end
