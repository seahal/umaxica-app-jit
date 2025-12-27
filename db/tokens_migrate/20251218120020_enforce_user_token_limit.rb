# frozen_string_literal: true

class EnforceUserTokenLimit < ActiveRecord::Migration[8.2]
  FUNCTION_NAME = "check_user_tokens_limit"
  TRIGGER_NAME = "enforce_user_tokens_limit"
  LIMIT = 2

  def up
    execute <<~SQL.squish
      CREATE OR REPLACE FUNCTION #{FUNCTION_NAME}()
      RETURNS trigger AS $$
      DECLARE
        token_count integer;
      BEGIN
        SELECT COUNT(*) INTO token_count FROM user_tokens WHERE user_id = NEW.user_id;
        IF token_count >= #{LIMIT} THEN
          RAISE EXCEPTION 'user_tokens limit (#{LIMIT}) exceeded for user %', NEW.user_id
            USING ERRCODE = '23514';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL.squish
      CREATE TRIGGER #{TRIGGER_NAME}
      BEFORE INSERT ON user_tokens
      FOR EACH ROW EXECUTE FUNCTION #{FUNCTION_NAME}();
    SQL
  end

  def down
    execute <<~SQL.squish
      DROP TRIGGER IF EXISTS #{TRIGGER_NAME} ON user_tokens;
    SQL

    execute <<~SQL.squish
      DROP FUNCTION IF EXISTS #{FUNCTION_NAME}();
    SQL
  end
end
