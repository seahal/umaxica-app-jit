# frozen_string_literal: true

class AllowPendingSessionTokens < ActiveRecord::Migration[8.2]
  USER_FUNCTION = "check_user_tokens_limit"
  USER_TRIGGER = "enforce_user_tokens_limit"
  STAFF_FUNCTION = "check_staff_tokens_limit"
  STAFF_TRIGGER = "enforce_staff_tokens_limit"
  LIMIT = 2

  def up
    adjust_user_limit
    adjust_staff_limit
  end

  def down
    revert_user_limit
    revert_staff_limit
  end

  private

  def adjust_user_limit
    return unless table_exists?(:user_tokens)

    safety_assured do
      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{USER_FUNCTION}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count FROM user_tokens WHERE user_id = NEW.user_id;
          IF token_count >= #{LIMIT + 1} THEN
            RAISE EXCEPTION 'user_tokens pending limit (#{LIMIT + 1}) exceeded for user %', NEW.user_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      execute <<~SQL.squish
        DROP TRIGGER IF EXISTS #{USER_TRIGGER} ON user_tokens;
      SQL

      execute <<~SQL.squish
        CREATE TRIGGER #{USER_TRIGGER}
        BEFORE INSERT ON user_tokens
        FOR EACH ROW EXECUTE FUNCTION #{USER_FUNCTION}();
      SQL
    end
  end

  def adjust_staff_limit
    return unless table_exists?(:staff_tokens)

    safety_assured do
      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{STAFF_FUNCTION}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count FROM staff_tokens WHERE staff_id = NEW.staff_id;
          IF token_count >= #{LIMIT + 1} THEN
            RAISE EXCEPTION 'staff_tokens pending limit (#{LIMIT + 1}) exceeded for staff %', NEW.staff_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      execute <<~SQL.squish
        DROP TRIGGER IF EXISTS #{STAFF_TRIGGER} ON staff_tokens;
      SQL

      execute <<~SQL.squish
        CREATE TRIGGER #{STAFF_TRIGGER}
        BEFORE INSERT ON staff_tokens
        FOR EACH ROW EXECUTE FUNCTION #{STAFF_FUNCTION}();
      SQL
    end
  end

  def revert_user_limit
    return unless table_exists?(:user_tokens)

    safety_assured do
      execute <<~SQL.squish
        DROP TRIGGER IF EXISTS #{USER_TRIGGER} ON user_tokens;
      SQL

      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{USER_FUNCTION}()
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
        CREATE TRIGGER #{USER_TRIGGER}
        BEFORE INSERT ON user_tokens
        FOR EACH ROW EXECUTE FUNCTION #{USER_FUNCTION}();
      SQL
    end
  end

  def revert_staff_limit
    return unless table_exists?(:staff_tokens)

    safety_assured do
      execute <<~SQL.squish
        DROP TRIGGER IF EXISTS #{STAFF_TRIGGER} ON staff_tokens;
      SQL

      execute <<~SQL.squish
        CREATE OR REPLACE FUNCTION #{STAFF_FUNCTION}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count FROM staff_tokens WHERE staff_id = NEW.staff_id;
          IF token_count >= #{LIMIT} THEN
            RAISE EXCEPTION 'staff_tokens limit (#{LIMIT}) exceeded for staff %', NEW.staff_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      execute <<~SQL.squish
        CREATE TRIGGER #{STAFF_TRIGGER}
        BEFORE INSERT ON staff_tokens
        FOR EACH ROW EXECUTE FUNCTION #{STAFF_FUNCTION}();
      SQL
    end
  end
end
