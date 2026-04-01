# frozen_string_literal: true

class CreateAppPreferencesInPrincipal < ActiveRecord::Migration[8.2]
  def change # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    safety_assured do
    create_table(:app_preference_binding_methods, id: :bigint)
    create_table(:app_preference_dbsc_statuses, id: :bigint)
    create_table(:app_preference_statuses, id: :bigint)
    create_table(:app_preference_language_options, id: :bigint)
    create_table(:app_preference_region_options, id: :bigint)
    create_table(:app_preference_timezone_options, id: :bigint)
    create_table(:app_preference_colortheme_options, id: :bigint)

    create_table(:app_preferences) do |t|
      t.bigint(:binding_method_id, null: false, default: 0)
      t.datetime(:compromised_at)
      t.text(:dbsc_challenge)
      t.datetime(:dbsc_challenge_issued_at)
      t.jsonb(:dbsc_public_key)
      t.string(:dbsc_session_id)
      t.bigint(:dbsc_status_id, null: false, default: 0)
      t.string(:device_id)
      t.datetime(:expires_at)
      t.string(:jti)
      t.string(:public_id, null: false)
      t.bigint(:replaced_by_id)
      t.datetime(:revoked_at)
      t.bigint(:status_id, null: false, default: 2)
      t.binary(:token_digest)
      t.datetime(:used_at)
      t.timestamps
    end

    add_index(:app_preferences, :binding_method_id)
    add_index(:app_preferences, :dbsc_session_id, unique: true)
    add_index(:app_preferences, :dbsc_status_id)
    add_index(:app_preferences, :device_id)
    add_index(:app_preferences, :jti, unique: true)
    add_index(:app_preferences, :public_id, unique: true)
    add_index(:app_preferences, :replaced_by_id)
    add_index(:app_preferences, :revoked_at)
    add_index(:app_preferences, :status_id)
    add_index(:app_preferences, :token_digest)
    add_index(:app_preferences, :used_at)

    create_table(:app_preference_cookies) do |t|
      t.bigint(:preference_id, null: false)
      t.uuid(:consent_version)
      t.boolean(:consented, default: false, null: false)
      t.datetime(:consented_at)
      t.boolean(:functional, default: false, null: false)
      t.boolean(:performant, default: false, null: false)
      t.boolean(:targetable, default: false, null: false)
      t.timestamps
    end

    add_index(:app_preference_cookies, :preference_id, unique: true)
    add_foreign_key(:app_preference_cookies, :app_preferences, column: :preference_id, validate: false)

    create_table(:app_preference_languages) do |t|
      t.bigint(:preference_id, null: false)
      t.bigint(:option_id, null: false)
      t.timestamps
    end

    add_index(:app_preference_languages, :preference_id, unique: true)
    add_index(:app_preference_languages, :option_id)
    add_foreign_key(:app_preference_languages, :app_preferences, column: :preference_id, validate: false)
    add_foreign_key(:app_preference_languages, :app_preference_language_options, column: :option_id, name: "fk_app_preference_languages_on_option_id")

    create_table(:app_preference_regions) do |t|
      t.bigint(:preference_id, null: false)
      t.bigint(:option_id, null: false)
      t.timestamps
    end

    add_index(:app_preference_regions, :preference_id, unique: true)
    add_index(:app_preference_regions, :option_id)
    add_foreign_key(:app_preference_regions, :app_preferences, column: :preference_id, validate: false)
    add_foreign_key(:app_preference_regions, :app_preference_region_options, column: :option_id, name: "fk_app_preference_regions_on_option_id")

    create_table(:app_preference_timezones) do |t|
      t.bigint(:preference_id, null: false)
      t.bigint(:option_id, null: false)
      t.timestamps
    end

    add_index(:app_preference_timezones, :preference_id, unique: true)
    add_index(:app_preference_timezones, :option_id)
    add_foreign_key(:app_preference_timezones, :app_preferences, column: :preference_id, validate: false)
    add_foreign_key(:app_preference_timezones, :app_preference_timezone_options, column: :option_id, name: "fk_app_preference_timezones_on_option_id")

    create_table(:app_preference_colorthemes) do |t|
      t.bigint(:preference_id, null: false)
      t.bigint(:option_id, null: false)
      t.timestamps
    end

    add_index(:app_preference_colorthemes, :preference_id, unique: true)
    add_index(:app_preference_colorthemes, :option_id)
    add_foreign_key(:app_preference_colorthemes, :app_preferences, column: :preference_id, validate: false)
    add_foreign_key(:app_preference_colorthemes, :app_preference_colortheme_options, column: :option_id, name: "fk_app_preference_colorthemes_on_option_id")

    create_table(:user_app_preferences, id: :bigserial) do |t|
      t.bigint(:user_id, null: false)
      t.references(:app_preference, null: false, foreign_key: { on_delete: :cascade, validate: false }, type: :bigserial)
      t.timestamps
    end

    add_index(:user_app_preferences, :user_id)
    add_index(:user_app_preferences, %i[user_id app_preference_id], unique: true)
    add_foreign_key(:user_app_preferences, :users, column: :user_id, validate: false)

    add_foreign_key(:app_preferences, :app_preference_binding_methods, column: :binding_method_id, name: "fk_app_preferences_on_binding_method_id", validate: false)
    add_foreign_key(:app_preferences, :app_preference_dbsc_statuses, column: :dbsc_status_id, name: "fk_app_preferences_on_dbsc_status_id", validate: false)
    add_foreign_key(:app_preferences, :app_preference_statuses, column: :status_id, name: "fk_app_preferences_on_status_id", validate: false)
    add_foreign_key(:app_preferences, :app_preferences, column: :replaced_by_id, on_delete: :nullify, validate: false)

    seed_reference_ids(:app_preference_binding_methods, [0, 1, 2])
    seed_reference_ids(:app_preference_dbsc_statuses, [0, 1, 2, 3, 4])
    seed_reference_ids(:app_preference_statuses, [1, 2])
    seed_reference_ids(:app_preference_language_options, [1, 2])
    seed_reference_ids(:app_preference_region_options, [1, 2])
    seed_reference_ids(:app_preference_timezone_options, [1, 2])
    seed_reference_ids(:app_preference_colortheme_options, [1, 2, 3])
    end
  end

  private

  def seed_reference_ids(table_name, ids)
    ids.each do |id|
      execute(<<~SQL.squish)
        INSERT INTO #{table_name} (id)
        VALUES (#{connection.quote(id)})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
