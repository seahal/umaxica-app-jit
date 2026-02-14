# frozen_string_literal: true

class CreateBehaviorTables < ActiveRecord::Migration[8.2]
  def up
    # Create all Behavior tables with correct columns
    %w(
      app_contact app_document app_timeline
      com_contact com_document com_timeline
      org_contact org_document org_timeline
    ).each do |prefix|
      create_table("#{prefix}_behavior_events", if_not_exists: true)
      create_table("#{prefix}_behavior_levels", if_not_exists: true)

      create_table("#{prefix}_behaviors", if_not_exists: true) do |t|
        t.bigint "subject_id", null: false
        t.string "subject_type", null: false
        t.bigint "actor_id"
        t.string "actor_type"
        t.bigint "event_id"
        t.bigint "level_id"
        t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
        t.datetime "expires_at"
        t.timestamps
      end

      add_index "#{prefix}_behaviors", %w(subject_type subject_id)
      add_index "#{prefix}_behaviors", %w(actor_type actor_id)
      add_index "#{prefix}_behaviors", "event_id"
      add_index "#{prefix}_behaviors", "level_id"
    end
  end

  def down
    # Tables remain for data integrity
  end
end
