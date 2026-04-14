# frozen_string_literal: true

class CreateMessageSearchBillingBehaviorTables < ActiveRecord::Migration[8.1]
  def change
    # Message behavior tables
    create_table("message_behavior_events") do |t|
    end

    create_table("message_behavior_levels") do |t|
    end

    create_table("message_behaviors") do |t|
      t.bigint("actor_id")
      t.string("actor_type")
      t.datetime("created_at", null: false)
      t.bigint("event_id", null: false)
      t.datetime("expires_at")
      t.bigint("level_id", null: false)
      t.datetime("occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false)
      t.bigint("subject_id", null: false)
      t.string("subject_type", null: false)
      t.datetime("updated_at", null: false)

      t.index(["actor_type", "actor_id"], name: "index_message_behaviors_on_actor_type_and_actor_id")
      t.index(["event_id"], name: "index_message_behaviors_on_event_id")
      t.index(["level_id"], name: "index_message_behaviors_on_level_id")
      t.index(["subject_id"], name: "index_message_behaviors_on_subject_id")
      t.index(["subject_type", "subject_id"], name: "index_message_behaviors_on_subject_type_and_subject_id")
    end

    # Search behavior tables (same pattern)
    create_table("search_behavior_events") do |t|
    end

    create_table("search_behavior_levels") do |t|
    end

    create_table("search_behaviors") do |t|
      t.bigint("actor_id")
      t.string("actor_type")
      t.datetime("created_at", null: false)
      t.bigint("event_id", null: false)
      t.datetime("expires_at")
      t.bigint("level_id", null: false)
      t.datetime("occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false)
      t.bigint("subject_id", null: false)
      t.string("subject_type", null: false)
      t.datetime("updated_at", null: false)

      t.index(["actor_type", "actor_id"], name: "index_search_behaviors_on_actor_type_and_actor_id")
      t.index(["event_id"], name: "index_search_behaviors_on_event_id")
      t.index(["level_id"], name: "index_search_behaviors_on_level_id")
      t.index(["subject_id"], name: "index_search_behaviors_on_subject_id")
      t.index(["subject_type", "subject_id"], name: "index_search_behaviors_on_subject_type_and_subject_id")
    end

    # Billing behavior tables (same pattern)
    create_table("billing_behavior_events") do |t|
    end

    create_table("billing_behavior_levels") do |t|
    end

    create_table("billing_behaviors") do |t|
      t.bigint("actor_id")
      t.string("actor_type")
      t.datetime("created_at", null: false)
      t.bigint("event_id", null: false)
      t.datetime("expires_at")
      t.bigint("level_id", null: false)
      t.datetime("occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false)
      t.bigint("subject_id", null: false)
      t.string("subject_type", null: false)
      t.datetime("updated_at", null: false)

      t.index(["actor_type", "actor_id"], name: "index_billing_behaviors_on_actor_type_and_actor_id")
      t.index(["event_id"], name: "index_billing_behaviors_on_event_id")
      t.index(["level_id"], name: "index_billing_behaviors_on_level_id")
      t.index(["subject_id"], name: "index_billing_behaviors_on_subject_id")
      t.index(["subject_type", "subject_id"], name: "index_billing_behaviors_on_subject_type_and_subject_id")
    end

    add_foreign_key("message_behaviors", "message_behavior_events", column: "event_id", validate: false)
    add_foreign_key("message_behaviors", "message_behavior_levels", column: "level_id", validate: false)
    add_foreign_key("search_behaviors", "search_behavior_events", column: "event_id", validate: false)
    add_foreign_key("search_behaviors", "search_behavior_levels", column: "level_id", validate: false)
    add_foreign_key("billing_behaviors", "billing_behavior_events", column: "event_id", validate: false)
    add_foreign_key("billing_behaviors", "billing_behavior_levels", column: "level_id", validate: false)
  end
end
