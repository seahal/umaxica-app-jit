# frozen_string_literal: true

class CreateTokenBindingMethodsAndDbscStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    create_table(:user_token_binding_methods, id: :bigint)
    create_table(:staff_token_binding_methods, id: :bigint)
    create_table(:user_token_dbsc_statuses, id: :bigint)
    create_table(:staff_token_dbsc_statuses, id: :bigint)

    safety_assured do
      change_table(:user_tokens, bulk: true) do |t|
        t.bigint(:user_token_binding_method_id, null: false, default: 0)
        t.bigint(:user_token_dbsc_status_id, null: false, default: 0)
        t.string(:dbsc_session_id)
        t.jsonb(:dbsc_public_key)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
      end
    end

    add_foreign_key(
      :user_tokens, :user_token_binding_methods,
      name: "fk_user_tokens_on_user_token_binding_method_id",
      validate: false,
    )
    add_foreign_key(
      :user_tokens, :user_token_dbsc_statuses,
      name: "fk_user_tokens_on_user_token_dbsc_status_id",
      validate: false,
    )
    add_index(:user_tokens, :user_token_binding_method_id, algorithm: :concurrently)
    add_index(:user_tokens, :user_token_dbsc_status_id, algorithm: :concurrently)
    add_index(:user_tokens, :dbsc_session_id, unique: true, algorithm: :concurrently)

    safety_assured do
      change_table(:staff_tokens, bulk: true) do |t|
        t.bigint(:staff_token_binding_method_id, null: false, default: 0)
        t.bigint(:staff_token_dbsc_status_id, null: false, default: 0)
        t.string(:dbsc_session_id)
        t.jsonb(:dbsc_public_key)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
      end
    end

    add_foreign_key(
      :staff_tokens, :staff_token_binding_methods,
      name: "fk_staff_tokens_on_staff_token_binding_method_id",
      validate: false,
    )
    add_foreign_key(
      :staff_tokens, :staff_token_dbsc_statuses,
      name: "fk_staff_tokens_on_staff_token_dbsc_status_id",
      validate: false,
    )
    add_index(:staff_tokens, :staff_token_binding_method_id, algorithm: :concurrently)
    add_index(:staff_tokens, :staff_token_dbsc_status_id, algorithm: :concurrently)
    add_index(:staff_tokens, :dbsc_session_id, unique: true, algorithm: :concurrently)

    reversible do |dir|
      dir.up do
        seed_reference_ids(:user_token_binding_methods, [0, 1, 2])
        seed_reference_ids(:staff_token_binding_methods, [0, 1, 2])
        seed_reference_ids(:user_token_dbsc_statuses, [0, 1, 2, 3, 4])
        seed_reference_ids(:staff_token_dbsc_statuses, [0, 1, 2, 3, 4])
      end
    end
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
    end
  end
end
