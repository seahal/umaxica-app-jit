# frozen_string_literal: true

# Increase the user token limit from 2 to 3 to allow for one pending/restricted session.
# The limit becomes: 2 active sessions + 1 restricted session (waiting for resolution)
#
# This supports the "pending session" pattern where users who exceed the limit
# can still log in with a restricted session that only allows session management.
class IncreaseUserTokenLimitToThree < ActiveRecord::Migration[8.2]
  FUNCTION_NAME = "check_user_tokens_limit"
  TRIGGER_NAME = "enforce_user_tokens_limit"
  NEW_LIMIT = 3
  OLD_LIMIT = 2

  def up
    # Drop and recreate the function with new limit
    safety_assured do
      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{FUNCTION_NAME}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count FROM user_tokens WHERE user_id = NEW.user_id;
          IF token_count >= #{NEW_LIMIT} THEN
            RAISE EXCEPTION 'user_tokens limit (#{NEW_LIMIT}) exceeded for user %', NEW.user_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL
    end
  end

  def down
    # Restore original limit
    safety_assured do
      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{FUNCTION_NAME}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count FROM user_tokens WHERE user_id = NEW.user_id;
          IF token_count >= #{OLD_LIMIT} THEN
            RAISE EXCEPTION 'user_tokens limit (#{OLD_LIMIT}) exceeded for user %', NEW.user_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL
    end
  end
end
