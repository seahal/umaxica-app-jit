# frozen_string_literal: true

class AlignAppPreferenceActivityEventIds < ActiveRecord::Migration[8.1]
  # Realigns App event IDs to match Org/Com ordering:
  #
  # Old App IDs:                    New App IDs (= Org/Com):
  #   REFRESH_TOKEN_ROTATED = 1       CREATE_NEW_PREFERENCE_TOKEN = 1
  #   UPDATE_PREFERENCE_COOKIE = 2    REFRESH_TOKEN_ROTATED = 2
  #   UPDATE_PREFERENCE_COLORTHEME=3  UPDATE_PREFERENCE_COOKIE = 3
  #   RESET_BY_USER_DECISION = 4      UPDATE_PREFERENCE_LANGUAGE = 4
  #   UPDATE_PREFERENCE_TIMEZONE = 5  UPDATE_PREFERENCE_TIMEZONE = 5
  #   UPDATE_PREFERENCE_REGION = 6    RESET_BY_USER_DECISION = 6
  #   UPDATE_PREFERENCE_LANGUAGE = 7  UPDATE_PREFERENCE_REGION = 7
  #   CREATE_NEW_PREFERENCE_TOKEN = 8 UPDATE_PREFERENCE_COLORTHEME = 8
  #
  # Note: ID 5 (TIMEZONE) stays the same.

  OLD_TO_NEW = {
    1 => 100, # REFRESH_TOKEN_ROTATED -> temp
    2 => 101, # UPDATE_PREFERENCE_COOKIE -> temp
    3 => 102, # UPDATE_PREFERENCE_COLORTHEME -> temp
    4 => 103, # RESET_BY_USER_DECISION -> temp
    # 5 stays
    6 => 104, # UPDATE_PREFERENCE_REGION -> temp
    7 => 105, # UPDATE_PREFERENCE_LANGUAGE -> temp
    8 => 106, # CREATE_NEW_PREFERENCE_TOKEN -> temp
  }.freeze

  TEMP_TO_FINAL = {
    100 => 2, # REFRESH_TOKEN_ROTATED
    101 => 3, # UPDATE_PREFERENCE_COOKIE
    102 => 8, # UPDATE_PREFERENCE_COLORTHEME
    103 => 6, # RESET_BY_USER_DECISION
    104 => 7, # UPDATE_PREFERENCE_REGION
    105 => 4, # UPDATE_PREFERENCE_LANGUAGE
    106 => 1, # CREATE_NEW_PREFERENCE_TOKEN
  }.freeze

  def up
    safety_assured do
      # Ensure new event IDs exist in the events table
      (1..8).each do |id|
        execute("INSERT INTO app_preference_activity_events (id) VALUES (#{id}) ON CONFLICT DO NOTHING")
      end

      # Phase 1: Move old IDs to temporary IDs to avoid collisions
      OLD_TO_NEW.each do |old_id, temp_id|
        execute("INSERT INTO app_preference_activity_events (id) VALUES (#{temp_id}) ON CONFLICT DO NOTHING")
        execute("UPDATE app_preference_activities SET event_id = #{temp_id} WHERE event_id = #{old_id}")
      end

      # Phase 2: Move temporary IDs to final IDs
      TEMP_TO_FINAL.each do |temp_id, final_id|
        execute("UPDATE app_preference_activities SET event_id = #{final_id} WHERE event_id = #{temp_id}")
        execute("DELETE FROM app_preference_activity_events WHERE id = #{temp_id}")
      end

      # Add NOTHING=0 to Org/Com activity levels
      execute("INSERT INTO org_preference_activity_levels (id) VALUES (0) ON CONFLICT DO NOTHING")
      execute("INSERT INTO com_preference_activity_levels (id) VALUES (0) ON CONFLICT DO NOTHING")
    end
  end

  def down
    # Reverse mapping is not implemented; this is a one-way alignment.
    raise ActiveRecord::IrreversibleMigration
  end
end
