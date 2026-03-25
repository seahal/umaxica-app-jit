# frozen_string_literal: true

class ConvertAllPreferencePksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension("citext") unless extension_enabled?("citext")

    # Drop all preference tables with int/serial/string PKs
    drop_table(:app_preference_statuses, if_exists: true, force: :cascade)
    drop_table(:com_preference_statuses, if_exists: true, force: :cascade)
    drop_table(:org_preference_statuses, if_exists: true, force: :cascade)
    drop_table(:app_preference_language_options, if_exists: true, force: :cascade)
    drop_table(:com_preference_language_options, if_exists: true, force: :cascade)
    drop_table(:org_preference_language_options, if_exists: true, force: :cascade)
    drop_table(:app_preference_region_options, if_exists: true, force: :cascade)
    drop_table(:com_preference_region_options, if_exists: true, force: :cascade)
    drop_table(:org_preference_region_options, if_exists: true, force: :cascade)
    drop_table(:app_preference_timezone_options, if_exists: true, force: :cascade)
    drop_table(:com_preference_timezone_options, if_exists: true, force: :cascade)
    drop_table(:org_preference_timezone_options, if_exists: true, force: :cascade)
    drop_table(:app_preference_colortheme_options, if_exists: true, force: :cascade)
    drop_table(:com_preference_colortheme_options, if_exists: true, force: :cascade)
    drop_table(:org_preference_colortheme_options, if_exists: true, force: :cascade)

    # Recreate all tables with bigint PK + code column
    create_table(:app_preference_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:com_preference_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:org_preference_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:app_preference_language_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:com_preference_language_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:org_preference_language_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:app_preference_region_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:com_preference_region_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:org_preference_region_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:app_preference_timezone_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:com_preference_timezone_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:org_preference_timezone_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:app_preference_colortheme_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:com_preference_colortheme_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:org_preference_colortheme_options, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
