# frozen_string_literal: true

class ConvertPreferencePks < ActiveRecord::Migration[8.0]
  def up
    # -------------------------------------------------------------------------
    # DEPENDENTS (Drop)
    # -------------------------------------------------------------------------
    suffixes = %w(regions timezones languages colorthemes cookies)
    prefixes = %w(app org com)

    prefixes.each do |prefix|
      suffixes.each do |suffix|
        drop_table(:"#{prefix}_preference_#{suffix}", if_exists: true)
      end
      drop_table(:"#{prefix}_preferences", if_exists: true)
    end

    # -------------------------------------------------------------------------
    # PARENTS (Recreate with Bigint)
    # -------------------------------------------------------------------------
    prefixes.each do |prefix|
      create_table(:"#{prefix}_preferences") do |t|
        t.string(:public_id)
        t.datetime(:expires_at)
        t.binary(:token_digest)
        t.string(:status_id, default: "NEYO", null: false)
        t.timestamps
        t.index(:status_id)
      end
    end

    # -------------------------------------------------------------------------
    # CHILDREN (Recreate with Bigint FK)
    # -------------------------------------------------------------------------
    prefixes.each do |prefix|
      # Regions
      create_table(:"#{prefix}_preference_regions") do |t|
        t.bigint(:preference_id, null: false)
        t.integer(:option_id, limit: 2)
        t.timestamps
        t.index(:preference_id, unique: true)
        t.index(:option_id)
      end

      # Timezones
      create_table(:"#{prefix}_preference_timezones") do |t|
        t.bigint(:preference_id, null: false)
        t.integer(:option_id, limit: 2)
        t.timestamps
        t.index(:preference_id, unique: true)
        t.index(:option_id)
      end

      # Languages
      create_table(:"#{prefix}_preference_languages") do |t|
        t.bigint(:preference_id, null: false)
        t.integer(:option_id, limit: 2)
        t.timestamps
        t.index(:preference_id, unique: true)
        t.index(:option_id)
      end

      # Colorthemes
      create_table(:"#{prefix}_preference_colorthemes") do |t|
        t.bigint(:preference_id, null: false)
        t.integer(:option_id, limit: 2)
        t.timestamps
        t.index(:preference_id, unique: true)
        t.index(:option_id)
      end

      # Cookies
      create_table(:"#{prefix}_preference_cookies") do |t|
        t.bigint(:preference_id, null: false)
        t.timestamps
        t.boolean(:targetable, null: false, default: false)
        t.boolean(:performant, null: false, default: false)
        t.boolean(:functional, null: false, default: false)
        t.boolean(:consented, null: false, default: false)
        t.datetime(:consented_at)
        t.uuid(:consent_version)
        t.index(:preference_id, unique: true)
      end
    end

    # -------------------------------------------------------------------------
    # Foreign Keys
    # -------------------------------------------------------------------------
    prefixes.each do |prefix|
      suffixes.each do |suffix|
        add_foreign_key(
          :"#{prefix}_preference_#{suffix}", :"#{prefix}_preferences", column: :preference_id,
                                                                       validate: false,
        )
      end

      # Option FKs (referencing existing tables which were not dropped)
      # We assume tables like app_preference_region_options exist and have string IDs.
      # We validate: false to avoid immediate checks if empty, or just standard fk.
      add_foreign_key(
        :"#{prefix}_preference_regions", :"#{prefix}_preference_region_options", column: :option_id,
                                                                                 primary_key: :id, validate: false,
      )
      add_foreign_key(
        :"#{prefix}_preference_timezones", :"#{prefix}_preference_timezone_options", column: :option_id,
                                                                                     primary_key: :id, validate: false,
      )
      add_foreign_key(
        :"#{prefix}_preference_languages", :"#{prefix}_preference_language_options", column: :option_id,
                                                                                     primary_key: :id, validate: false,
      )
      add_foreign_key(
        :"#{prefix}_preference_colorthemes", :"#{prefix}_preference_colortheme_options",
        column: :option_id, primary_key: :id, validate: false,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
