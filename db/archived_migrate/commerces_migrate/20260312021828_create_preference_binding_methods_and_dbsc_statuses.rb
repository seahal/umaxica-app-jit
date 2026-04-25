# frozen_string_literal: true

class CreatePreferenceBindingMethodsAndDbscStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    create_table(:app_preference_binding_methods, id: :bigint)
    create_table(:org_preference_binding_methods, id: :bigint)
    create_table(:com_preference_binding_methods, id: :bigint)
    create_table(:app_preference_dbsc_statuses, id: :bigint)
    create_table(:org_preference_dbsc_statuses, id: :bigint)
    create_table(:com_preference_dbsc_statuses, id: :bigint)

    safety_assured do
      change_table(:app_preferences, bulk: true) do |t|
        t.bigint(:binding_method_id, null: false, default: 0)
        t.bigint(:dbsc_status_id, null: false, default: 0)
        t.string(:dbsc_session_id)
        t.jsonb(:dbsc_public_key)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
      end
    end

    add_foreign_key(
      :app_preferences, :app_preference_binding_methods, column: :binding_method_id,
                                                         name: "fk_app_preferences_on_binding_method_id",
                                                         validate: false,
    )
    add_foreign_key(
      :app_preferences, :app_preference_dbsc_statuses, column: :dbsc_status_id,
                                                       name: "fk_app_preferences_on_dbsc_status_id",
                                                       validate: false,
    )
    add_index(:app_preferences, :binding_method_id, algorithm: :concurrently)
    add_index(:app_preferences, :dbsc_status_id, algorithm: :concurrently)
    add_index(:app_preferences, :dbsc_session_id, unique: true, algorithm: :concurrently)

    safety_assured do
      change_table(:org_preferences, bulk: true) do |t|
        t.bigint(:binding_method_id, null: false, default: 0)
        t.bigint(:dbsc_status_id, null: false, default: 0)
        t.string(:dbsc_session_id)
        t.jsonb(:dbsc_public_key)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
      end
    end

    add_foreign_key(
      :org_preferences, :org_preference_binding_methods, column: :binding_method_id,
                                                         name: "fk_org_preferences_on_binding_method_id",
                                                         validate: false,
    )
    add_foreign_key(
      :org_preferences, :org_preference_dbsc_statuses, column: :dbsc_status_id,
                                                       name: "fk_org_preferences_on_dbsc_status_id",
                                                       validate: false,
    )
    add_index(:org_preferences, :binding_method_id, algorithm: :concurrently)
    add_index(:org_preferences, :dbsc_status_id, algorithm: :concurrently)
    add_index(:org_preferences, :dbsc_session_id, unique: true, algorithm: :concurrently)

    safety_assured do
      change_table(:com_preferences, bulk: true) do |t|
        t.bigint(:binding_method_id, null: false, default: 0)
        t.bigint(:dbsc_status_id, null: false, default: 0)
        t.string(:dbsc_session_id)
        t.jsonb(:dbsc_public_key)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
      end
    end

    add_foreign_key(
      :com_preferences, :com_preference_binding_methods, column: :binding_method_id,
                                                         name: "fk_com_preferences_on_binding_method_id",
                                                         validate: false,
    )
    add_foreign_key(
      :com_preferences, :com_preference_dbsc_statuses, column: :dbsc_status_id,
                                                       name: "fk_com_preferences_on_dbsc_status_id",
                                                       validate: false,
    )
    add_index(:com_preferences, :binding_method_id, algorithm: :concurrently)
    add_index(:com_preferences, :dbsc_status_id, algorithm: :concurrently)
    add_index(:com_preferences, :dbsc_session_id, unique: true, algorithm: :concurrently)

    reversible do |dir|
      dir.up do
        seed_reference_ids(:app_preference_binding_methods, [0, 1, 2])
        seed_reference_ids(:org_preference_binding_methods, [0, 1, 2])
        seed_reference_ids(:com_preference_binding_methods, [0, 1, 2])
        seed_reference_ids(:app_preference_dbsc_statuses, [0, 1, 2, 3, 4])
        seed_reference_ids(:org_preference_dbsc_statuses, [0, 1, 2, 3, 4])
        seed_reference_ids(:com_preference_dbsc_statuses, [0, 1, 2, 3, 4])
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
