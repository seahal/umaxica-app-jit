# frozen_string_literal: true

class CreateOrgPreferencesInOperator < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      create_table(:org_preference_binding_methods, id: :bigint)
      create_table(:org_preference_dbsc_statuses, id: :bigint)
      create_table(:org_preference_statuses, id: :bigint)
      create_table(:org_preference_language_options, id: :bigint)
      create_table(:org_preference_region_options, id: :bigint)
      create_table(:org_preference_timezone_options, id: :bigint)
      create_table(:org_preference_colortheme_options, id: :bigint)

      create_table(:org_preferences) do |t|
        t.bigint :binding_method_id, default: 0, null: false
        t.datetime :compromised_at
        t.datetime :created_at, null: false
        t.text :dbsc_challenge
        t.datetime :dbsc_challenge_issued_at
        t.jsonb :dbsc_public_key
        t.string :dbsc_session_id
        t.bigint :dbsc_status_id, default: 0, null: false
        t.string :device_id
        t.datetime :expires_at
        t.string :jti
        t.string :public_id, null: false
        t.bigint :replaced_by_id
        t.datetime :revoked_at
        t.bigint :status_id, default: 2, null: false
        t.binary :token_digest
        t.datetime :updated_at, null: false
        t.datetime :used_at

        t.index :binding_method_id, name: "index_org_preferences_on_binding_method_id"
        t.index :dbsc_session_id, name: "index_org_preferences_on_dbsc_session_id", unique: true
        t.index :dbsc_status_id, name: "index_org_preferences_on_dbsc_status_id"
        t.index :device_id, name: "index_org_preferences_on_device_id"
        t.index :jti, name: "index_org_preferences_on_jti", unique: true
        t.index :public_id, name: "index_org_preferences_on_public_id", unique: true
        t.index :replaced_by_id, name: "index_org_preferences_on_replaced_by_id"
        t.index :revoked_at, name: "index_org_preferences_on_revoked_at"
        t.index :status_id, name: "index_org_preferences_on_status_id"
        t.index :token_digest, name: "index_org_preferences_on_token_digest"
        t.index :used_at, name: "index_org_preferences_on_used_at"
      end

      create_table(:org_preference_cookies) do |t|
        t.bigint :preference_id, null: false
        t.uuid :consent_version
        t.boolean :consented, default: false, null: false
        t.datetime :consented_at
        t.datetime :created_at, null: false
        t.boolean :functional, default: false, null: false
        t.boolean :performant, default: false, null: false
        t.boolean :targetable, default: false, null: false
        t.datetime :updated_at, null: false

        t.index :preference_id, name: "index_org_preference_cookies_on_preference_id", unique: true
      end

      create_table(:org_preference_languages) do |t|
        t.bigint :preference_id, null: false
        t.bigint :option_id, null: false
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false

        t.index :option_id, name: "index_org_preference_languages_on_option_id"
        t.index :preference_id, name: "index_org_preference_languages_on_preference_id", unique: true
      end

      create_table(:org_preference_regions) do |t|
        t.bigint :preference_id, null: false
        t.bigint :option_id, null: false
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false

        t.index :option_id, name: "index_org_preference_regions_on_option_id"
        t.index :preference_id, name: "index_org_preference_regions_on_preference_id", unique: true
      end

      create_table(:org_preference_timezones) do |t|
        t.bigint :preference_id, null: false
        t.bigint :option_id, null: false
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false

        t.index :option_id, name: "index_org_preference_timezones_on_option_id"
        t.index :preference_id, name: "index_org_preference_timezones_on_preference_id", unique: true
      end

      create_table(:org_preference_colorthemes) do |t|
        t.bigint :preference_id, null: false
        t.bigint :option_id, null: false
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false

        t.index :option_id, name: "index_org_preference_colorthemes_on_option_id"
        t.index :preference_id, name: "index_org_preference_colorthemes_on_preference_id", unique: true
      end

      create_table(:staff_org_preferences) do |t|
        t.bigint :org_preference_id, null: false
        t.bigint :staff_id, null: false
        t.datetime :created_at, null: false
        t.datetime :updated_at, null: false

        t.index :org_preference_id, name: "index_staff_org_preferences_on_org_preference_id"
        t.index %i[staff_id org_preference_id], name: "index_staff_org_preferences_on_staff_id_and_org_preference_id", unique: true
      end

      add_foreign_key :org_preferences, :org_preference_binding_methods, column: :binding_method_id, name: "fk_org_preferences_on_binding_method_id", validate: false
      add_foreign_key :org_preferences, :org_preference_dbsc_statuses, column: :dbsc_status_id, name: "fk_org_preferences_on_dbsc_status_id", validate: false
      add_foreign_key :org_preferences, :org_preference_statuses, column: :status_id, name: "fk_org_preferences_on_status_id", validate: false
      add_foreign_key :org_preferences, :org_preferences, column: :replaced_by_id, on_delete: :nullify, validate: false

      add_foreign_key :org_preference_cookies, :org_preferences, column: :preference_id, validate: false
      add_foreign_key :org_preference_languages, :org_preferences, column: :preference_id, validate: false
      add_foreign_key :org_preference_regions, :org_preferences, column: :preference_id, validate: false
      add_foreign_key :org_preference_timezones, :org_preferences, column: :preference_id, validate: false
      add_foreign_key :org_preference_colorthemes, :org_preferences, column: :preference_id, validate: false

      add_foreign_key :org_preference_languages, :org_preference_language_options, column: :option_id, name: "fk_org_preference_languages_on_option_id", validate: false
      add_foreign_key :org_preference_regions, :org_preference_region_options, column: :option_id, name: "fk_org_preference_regions_on_option_id", validate: false
      add_foreign_key :org_preference_timezones, :org_preference_timezone_options, column: :option_id, name: "fk_org_preference_timezones_on_option_id", validate: false
      add_foreign_key :org_preference_colorthemes, :org_preference_colortheme_options, column: :option_id, name: "fk_org_preference_colorthemes_on_option_id", validate: false

      add_foreign_key :staff_org_preferences, :org_preferences, on_delete: :cascade, validate: false
      add_foreign_key :staff_org_preferences, :staffs, validate: false

      seed_reference_ids(:org_preference_binding_methods, [0, 1, 2])
      seed_reference_ids(:org_preference_dbsc_statuses, [0, 1, 2, 3, 4])
      seed_reference_ids(:org_preference_statuses, [1, 2])
      seed_reference_ids(:org_preference_language_options, [1, 2])
      seed_reference_ids(:org_preference_region_options, [1, 2])
      seed_reference_ids(:org_preference_timezone_options, [1, 2])
      seed_reference_ids(:org_preference_colortheme_options, [1, 2, 3])
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
