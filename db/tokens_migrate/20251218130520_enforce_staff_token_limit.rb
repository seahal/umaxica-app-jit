class EnforceStaffTokenLimit < ActiveRecord::Migration[8.2]
  FUNCTION_NAME = "check_staff_tokens_limit"
  TRIGGER_NAME = "enforce_staff_tokens_limit"
  LIMIT = 2

  def up
    return unless table_exists?(:staff_tokens)

    execute <<~SQL.squish
      CREATE OR REPLACE FUNCTION #{FUNCTION_NAME}()
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
      CREATE TRIGGER #{TRIGGER_NAME}
      BEFORE INSERT ON staff_tokens
      FOR EACH ROW EXECUTE FUNCTION #{FUNCTION_NAME}();
    SQL
  end

  def down
    return unless table_exists?(:staff_tokens)

    execute <<~SQL.squish
      DROP TRIGGER IF EXISTS #{TRIGGER_NAME} ON staff_tokens;
    SQL

    execute <<~SQL.squish
      DROP FUNCTION IF EXISTS #{FUNCTION_NAME}();
    SQL
  end
end
