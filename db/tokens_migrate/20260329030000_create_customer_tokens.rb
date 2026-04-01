# frozen_string_literal: true

class CreateCustomerTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  FUNCTION_NAME = "check_customer_tokens_limit"
  TRIGGER_NAME = "enforce_customer_tokens_limit"
  LIMIT = 2

  def up
    create_table(:customer_token_binding_methods, id: :bigint)
    create_table(:customer_token_dbsc_statuses, id: :bigint)
    create_table(:customer_token_kinds, id: :bigint)
    create_table(:customer_token_statuses, id: :bigint)

    create_table(:customer_tokens, id: :bigint) do |t|
      t.bigint(:customer_id, null: false)
      t.bigint(:customer_token_binding_method_id, null: false, default: 0)
      t.bigint(:customer_token_dbsc_status_id, null: false, default: 0)
      t.bigint(:customer_token_kind_id, null: false, default: 1)
      t.bigint(:customer_token_status_id, null: false, default: 0)
      t.string(:status, limit: 20, null: false, default: "active")
      t.string(:public_id, limit: 21, null: false, default: "")
      t.binary(:refresh_token_digest)
      t.string(:refresh_token_family_id)
      t.integer(:refresh_token_generation, null: false, default: 0)
      t.datetime(:refresh_expires_at, null: false)
      t.string(:device_id, null: false, default: "")
      t.datetime(:revoked_at)
      t.datetime(:expired_at)
      t.datetime(:rotated_at)
      t.datetime(:last_used_at)
      t.datetime(:last_step_up_at)
      t.string(:last_step_up_scope)
      t.datetime(:compromised_at)
      t.datetime(:deletable_at, null: false, default: Float::INFINITY)
      t.string(:dbsc_session_id)
      t.jsonb(:dbsc_public_key)
      t.text(:dbsc_challenge)
      t.datetime(:dbsc_challenge_issued_at)
      t.timestamps
    end

    add_index(:customer_tokens, :compromised_at, algorithm: :concurrently)
    add_index(:customer_tokens, :dbsc_session_id, unique: true, algorithm: :concurrently)
    add_index(:customer_tokens, :deletable_at, algorithm: :concurrently)
    add_index(:customer_tokens, :device_id, algorithm: :concurrently)
    add_index(:customer_tokens, :expired_at, algorithm: :concurrently)
    add_index(:customer_tokens, :public_id, unique: true, algorithm: :concurrently)
    add_index(:customer_tokens, :refresh_expires_at, algorithm: :concurrently)
    add_index(:customer_tokens, :refresh_token_digest, unique: true, algorithm: :concurrently)
    add_index(:customer_tokens, :refresh_token_family_id, algorithm: :concurrently)
    add_index(:customer_tokens, :revoked_at, algorithm: :concurrently)
    add_index(:customer_tokens, [:customer_id, :last_step_up_at], algorithm: :concurrently)
    add_index(:customer_tokens, :customer_token_binding_method_id, algorithm: :concurrently)
    add_index(:customer_tokens, :customer_token_dbsc_status_id, algorithm: :concurrently)
    add_index(:customer_tokens, :customer_token_kind_id, algorithm: :concurrently)
    add_index(:customer_tokens, :customer_token_status_id, algorithm: :concurrently)
    add_index(:customer_tokens, :status, algorithm: :concurrently)

    add_check_constraint(:customer_tokens, "customer_token_kind_id >= 0", name: "chk_customer_tokens_kind_id_positive")
    add_check_constraint(
      :customer_tokens,
      "customer_token_status_id >= 0",
      name: "chk_customer_tokens_status_id_positive",
    )

    add_foreign_key(
      :customer_tokens,
      :customer_token_binding_methods,
      name: "fk_customer_tokens_on_customer_token_binding_method_id",
      validate: false,
    )
    add_foreign_key(
      :customer_tokens,
      :customer_token_dbsc_statuses,
      name: "fk_customer_tokens_on_customer_token_dbsc_status_id",
      validate: false,
    )
    add_foreign_key(
      :customer_tokens,
      :customer_token_kinds,
      name: "fk_customer_tokens_on_customer_token_kind_id",
      validate: false,
    )
    add_foreign_key(
      :customer_tokens,
      :customer_token_statuses,
      name: "fk_customer_tokens_on_customer_token_status_id",
      validate: false,
    )

    seed_reference_ids(:customer_token_binding_methods, [0, 1, 2])
    seed_reference_ids(:customer_token_dbsc_statuses, [0, 1, 2, 3, 4])
    seed_reference_ids(:customer_token_kinds, [1, 2, 3])
    seed_reference_ids(:customer_token_statuses, [0, 1, 2])

    create_limit_function!
  end

  def down
    drop_trigger_and_function!
    drop_table(:customer_tokens)
    drop_table(:customer_token_statuses)
    drop_table(:customer_token_kinds)
    drop_table(:customer_token_dbsc_statuses)
    drop_table(:customer_token_binding_methods)
  end

  private

  def seed_reference_ids(table_name, ids)
    safety_assured do
      ids.each do |id|
        execute(<<~SQL.squish)
          INSERT INTO #{table_name} (id)
          VALUES (#{connection.quote(id)})
          ON CONFLICT (id) DO NOTHING
        SQL
      end

      sequence_name = select_value("SELECT pg_get_serial_sequence(#{connection.quote(table_name.to_s)}, 'id')")
      return if sequence_name.blank?

      execute("SELECT setval(#{connection.quote(sequence_name)}, #{Integer(ids.max)}, true)")
    end
  end

  def create_limit_function!
    safety_assured do
      execute(<<~SQL.squish)
        CREATE OR REPLACE FUNCTION #{FUNCTION_NAME}()
        RETURNS trigger AS $$
        DECLARE
          token_count integer;
        BEGIN
          SELECT COUNT(*) INTO token_count
          FROM customer_tokens
          WHERE customer_id = NEW.customer_id;
          IF token_count >= #{LIMIT} THEN
            RAISE EXCEPTION 'customer_tokens limit (#{LIMIT}) exceeded for customer %', NEW.customer_id
              USING ERRCODE = '23514';
          END IF;
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      execute(<<~SQL.squish)
        CREATE TRIGGER #{TRIGGER_NAME}
        BEFORE INSERT ON customer_tokens
        FOR EACH ROW EXECUTE FUNCTION #{FUNCTION_NAME}();
      SQL
    end
  end

  def drop_trigger_and_function!
    safety_assured do
      execute(<<~SQL.squish)
        DROP TRIGGER IF EXISTS #{TRIGGER_NAME} ON customer_tokens;
      SQL
      execute(<<~SQL.squish)
        DROP FUNCTION IF EXISTS #{FUNCTION_NAME}();
      SQL
    end
  end
end
