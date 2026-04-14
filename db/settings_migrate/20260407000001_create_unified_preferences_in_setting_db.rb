# frozen_string_literal: true

class CreateUnifiedPreferencesInSettingDb < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      # Reference tables for status and binding methods
      create_table(:settings_preference_statuses, id: :bigint)
      create_table(:settings_preference_binding_methods, id: :bigint)
      create_table(:settings_preference_dbsc_statuses, id: :bigint)

      # Reference tables for options
      create_table(:settings_preference_language_options, id: :bigint)
      create_table(:settings_preference_region_options, id: :bigint)
      create_table(:settings_preference_timezone_options, id: :bigint)
      create_table(:settings_preference_colortheme_options, id: :bigint)

      # Main preferences table with polymorphic owner
      create_table(:settings_preferences) do |t|
        t.string(:owner_type, null: false)
        t.bigint(:owner_id, null: false)
        t.string(:public_id, null: false)

        # For token-based preferences (app, org, com)
        t.bigint(:binding_method_id, default: 0, null: false)
        t.bigint(:dbsc_status_id, default: 0, null: false)
        t.bigint(:status_id, default: 0, null: false)
        t.string(:jti)
        t.binary(:token_digest)
        t.string(:device_id)
        t.string(:device_id_digest)
        t.datetime(:expires_at)
        t.datetime(:revoked_at)
        t.datetime(:used_at)
        t.datetime(:compromised_at)
        t.string(:dbsc_session_id)
        t.text(:dbsc_challenge)
        t.datetime(:dbsc_challenge_issued_at)
        t.jsonb(:dbsc_public_key)
        t.bigint(:replaced_by_id)

        # Lifecycle columns (for future partitioning)
        t.datetime(:deletable_at)
        t.datetime(:shreddable_at)

        t.timestamps
      end

      add_index(:settings_preferences, %i(owner_type owner_id), unique: true)
      add_index(:settings_preferences, :public_id, unique: true)
      add_index(:settings_preferences, :jti, unique: true)
      add_index(:settings_preferences, :device_id)
      add_index(:settings_preferences, :device_id_digest)
      add_index(:settings_preferences, :status_id)
      add_index(:settings_preferences, :binding_method_id)
      add_index(:settings_preferences, :dbsc_status_id)
      add_index(:settings_preferences, :dbsc_session_id, unique: true)
      add_index(:settings_preferences, :replaced_by_id)
      add_index(:settings_preferences, :revoked_at)
      add_index(:settings_preferences, :token_digest)
      add_index(:settings_preferences, :used_at)
      add_index(:settings_preferences, :deletable_at)
      add_index(:settings_preferences, :shreddable_at)
      add_index(
        :settings_preferences, %i(owner_type owner_id status_id),
        name: "index_settings_preferences_on_owner_and_status",
      )

      # Cookie consent table
      create_table(:settings_preference_cookies) do |t|
        t.bigint(:preference_id, null: false)
        t.boolean(:consented, default: false, null: false)
        t.boolean(:functional, default: false, null: false)
        t.boolean(:performant, default: false, null: false)
        t.boolean(:targetable, default: false, null: false)
        t.datetime(:consented_at)
        t.uuid(:consent_version)
        t.timestamps
      end

      add_index(:settings_preference_cookies, :preference_id, unique: true)

      # Language association table
      create_table(:settings_preference_languages) do |t|
        t.bigint(:preference_id, null: false)
        t.bigint(:option_id, null: false)
        t.timestamps
      end

      add_index(:settings_preference_languages, :preference_id, unique: true)
      add_index(:settings_preference_languages, :option_id)

      # Timezone association table
      create_table(:settings_preference_timezones) do |t|
        t.bigint(:preference_id, null: false)
        t.bigint(:option_id, null: false)
        t.timestamps
      end

      add_index(:settings_preference_timezones, :preference_id, unique: true)
      add_index(:settings_preference_timezones, :option_id)

      # Region association table
      create_table(:settings_preference_regions) do |t|
        t.bigint(:preference_id, null: false)
        t.bigint(:option_id, null: false)
        t.timestamps
      end

      add_index(:settings_preference_regions, :preference_id, unique: true)
      add_index(:settings_preference_regions, :option_id)

      # Colortheme association table
      create_table(:settings_preference_colorthemes) do |t|
        t.bigint(:preference_id, null: false)
        t.bigint(:option_id, null: false)
        t.timestamps
      end

      add_index(:settings_preference_colorthemes, :preference_id, unique: true)
      add_index(:settings_preference_colorthemes, :option_id)

      # Activity tracking (for audit)
      create_table(:settings_preference_activities) do |t|
        t.bigint(:preference_id, null: false)
        t.bigint(:actor_id)
        t.string(:actor_type)
        t.string(:action, null: false)
        t.jsonb(:metadata, default: {})
        t.datetime(:created_at, null: false)
      end

      add_index(:settings_preference_activities, :preference_id)
      add_index(
        :settings_preference_activities, %i(actor_type actor_id),
        name: "index_settings_preference_activities_on_actor",
      )
      add_index(:settings_preference_activities, :created_at)

      # Foreign keys
      add_foreign_key(
        :settings_preference_cookies, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_cookies_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_languages, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_languages_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_languages, :settings_preference_language_options,
        column: :option_id, name: "fk_settings_preference_languages_on_option_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_timezones, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_timezones_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_timezones, :settings_preference_timezone_options,
        column: :option_id, name: "fk_settings_preference_timezones_on_option_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_regions, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_regions_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_regions, :settings_preference_region_options,
        column: :option_id, name: "fk_settings_preference_regions_on_option_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_colorthemes, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_colorthemes_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_colorthemes, :settings_preference_colortheme_options,
        column: :option_id, name: "fk_settings_preference_colorthemes_on_option_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preference_activities, :settings_preferences,
        column: :preference_id, name: "fk_settings_preference_activities_on_preference_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preferences, :settings_preferences,
        column: :replaced_by_id, on_delete: :nullify, validate: false,
      )
      add_foreign_key(
        :settings_preferences, :settings_preference_binding_methods,
        column: :binding_method_id, name: "fk_settings_preferences_on_binding_method_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preferences, :settings_preference_dbsc_statuses,
        column: :dbsc_status_id, name: "fk_settings_preferences_on_dbsc_status_id",
        validate: false,
      )
      add_foreign_key(
        :settings_preferences, :settings_preference_statuses,
        column: :status_id, name: "fk_settings_preferences_on_status_id",
        validate: false,
      )

      # Seed reference data
      seed_reference_ids(:settings_preference_statuses, [0, 1, 2])
      seed_reference_ids(:settings_preference_binding_methods, [0, 1, 2])
      seed_reference_ids(:settings_preference_dbsc_statuses, [0, 1, 2, 3, 4])
      seed_reference_ids(:settings_preference_language_options, [0, 1, 2])
      seed_reference_ids(:settings_preference_region_options, [0, 1, 2])
      seed_reference_ids(:settings_preference_timezone_options, [0, 1, 2])
      seed_reference_ids(:settings_preference_colortheme_options, [0, 1, 2, 3])
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
