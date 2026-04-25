# typed: false
# frozen_string_literal: true

namespace :preference do
  namespace :migrate do
    desc "Backfill legacy preferences (AppPreference, OrgPreference, ComPreference) into setting database"
    task backfill: :environment do
      require "sha3"

      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "Starting backfill of legacy preferences to setting database..."

      # Ensure setting database defaults exist
      Preference::StorageAdapter.ensure_setting_defaults!

      total_migrated = 0
      total_skipped = 0
      total_errors = 0

      # Migrate AppPreferences
      puts "\nMigrating AppPreferences..."
      AppPreference.find_each do |legacy_pref|
        result = migrate_legacy_preference(legacy_pref, "AppPreference", owner_type: "User")
        case result
        when :migrated then total_migrated += 1
        when :skipped then total_skipped += 1
        when :error then total_errors += 1
        end

        print "." if total_migrated % 100 == 0
      end

      # Migrate OrgPreferences
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\nMigrating OrgPreferences..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      OrgPreference.find_each do |legacy_pref|
        result = migrate_legacy_preference(legacy_pref, "OrgPreference", owner_type: "Staff")
        case result
        when :migrated then total_migrated += 1
        when :skipped then total_skipped += 1
        when :error then total_errors += 1
        end

        print "." if total_migrated % 100 == 0
      end

      # Migrate ComPreferences
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\nMigrating ComPreferences..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      ComPreference.find_each do |legacy_pref|
        result = migrate_legacy_preference(legacy_pref, "ComPreference", owner_type: "Customer")
        case result
        when :migrated then total_migrated += 1
        when :skipped then total_skipped += 1
        when :error then total_errors += 1
        end

        print "." if total_migrated % 100 == 0
      end

      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\n\nBackfill complete!"
      # rubocop:enable I18n/RailsI18n/DecorateString
      puts "  Migrated: #{total_migrated}"
      puts "  Skipped (already exist): #{total_skipped}"
      puts "  Errors: #{total_errors}"
    end

    desc "Verify consistency between legacy and setting database preferences"
    task verify: :environment do
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "Verifying preference consistency..."
      # rubocop:enable I18n/RailsI18n/DecorateString

      mismatches = []

      # Verify AppPreferences
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\nVerifying AppPreferences..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      AppPreference.find_each do |legacy_pref|
        setting_pref = SettingPreference.find_by(public_id: legacy_pref.public_id)
        if setting_pref.blank?
          mismatches << { public_id: legacy_pref.public_id, type: "AppPreference", issue: "missing in setting" }
          next
        end

        verify_preference_match(legacy_pref, setting_pref, mismatches)
      end

      # Verify OrgPreferences
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\nVerifying OrgPreferences..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      OrgPreference.find_each do |legacy_pref|
        setting_pref = SettingPreference.find_by(public_id: legacy_pref.public_id)
        if setting_pref.blank?
          mismatches << { public_id: legacy_pref.public_id, type: "OrgPreference", issue: "missing in setting" }
          next
        end

        verify_preference_match(legacy_pref, setting_pref, mismatches)
      end

      # Verify ComPreferences
      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\nVerifying ComPreferences..."
      # rubocop:enable I18n/RailsI18n/DecorateString
      ComPreference.find_each do |legacy_pref|
        setting_pref = SettingPreference.find_by(public_id: legacy_pref.public_id)
        if setting_pref.blank?
          mismatches << { public_id: legacy_pref.public_id, type: "ComPreference", issue: "missing in setting" }
          next
        end

        verify_preference_match(legacy_pref, setting_pref, mismatches)
      end

      # rubocop:disable I18n/RailsI18n/DecorateString
      puts "\n\nVerification complete!"
      # rubocop:enable I18n/RailsI18n/DecorateString
      if mismatches.empty?
        # rubocop:disable I18n/RailsI18n/DecorateString
        puts "  All preferences match!"
        # rubocop:enable I18n/RailsI18n/DecorateString
      else
        puts "  #{mismatches.size} mismatches found:"
        mismatches.first(10).each do |m|
          puts "    - #{m[:type]} #{m[:public_id]}: #{m[:issue]}"
        end
        puts "    ... and #{mismatches.size - 10} more" if mismatches.size > 10
      end
    end

    desc "Enable setting database for preferences (set USE_SETTING_DATABASE=true)"
    task enable: :environment do
      puts "To enable the setting database for preferences, set the environment variable:"
      puts "  USE_SETTING_DATABASE=true"
      puts ""
      puts "Add this to your environment configuration:"
      puts "  export USE_SETTING_DATABASE=true"
      puts ""
      puts "Or for a specific deployment:"
      puts "  USE_SETTING_DATABASE=true bundle exec rails server"
    end

    private

    define_method(:migrate_legacy_preference) do |legacy_pref, preference_type, owner_type:|
      existing = SettingPreference.find_by(public_id: legacy_pref.public_id)
      return :skipped if existing.present?

      SettingRecord.connected_to(role: :writing) do
        SettingPreference.transaction do
          # Create the main preference record
          setting_pref = SettingPreference.create!(
            public_id: legacy_pref.public_id,
            owner_type: owner_type,
            owner_id: 0, # Anonymous by default; adoption will link to actual user if logged in
            jti: legacy_pref.jti,
            token_digest: legacy_pref.token_digest,
            device_id: legacy_pref.device_id,
            device_id_digest: legacy_pref.device_id_digest,
            status_id: map_status_id(legacy_pref.status_id, preference_type),
            binding_method_id: map_binding_method_id(legacy_pref.binding_method_id, preference_type),
            dbsc_status_id: map_dbsc_status_id(legacy_pref.dbsc_status_id, preference_type),
            dbsc_session_id: legacy_pref.dbsc_session_id,
            dbsc_challenge: legacy_pref.dbsc_challenge,
            dbsc_challenge_issued_at: legacy_pref.dbsc_challenge_issued_at,
            dbsc_public_key: legacy_pref.dbsc_public_key,
            expires_at: legacy_pref.expires_at,
            used_at: legacy_pref.used_at,
            revoked_at: legacy_pref.revoked_at,
            compromised_at: legacy_pref.compromised_at,
            deletable_at: legacy_pref.deletable_at,
            shreddable_at: legacy_pref.shreddable_at,
            replaced_by_id: find_replacement_id(legacy_pref.replaced_by_id, preference_type),
            created_at: legacy_pref.created_at,
            updated_at: legacy_pref.updated_at,
          )

          # Migrate child records
          migrate_child_records(legacy_pref, setting_pref, preference_type)

          :migrated
        end
      end
    rescue StandardError => e
      Rails.event.error(
        "preference.migrate.backfill_error",
        error: e.class.name,
        message: e.message,
        public_id: legacy_pref.public_id,
        preference_type: preference_type,
      )
      puts "\nError migrating #{preference_type} #{legacy_pref.public_id}: #{e.message}"
      :error
    end

    define_method(:migrate_child_records) do |legacy_pref, setting_pref, preference_type|
      prefix = preference_type.delete_suffix("Preference").downcase

      # Migrate cookie
      legacy_cookie = legacy_pref.public_send("#{prefix}_preference_cookie") rescue nil
      if legacy_cookie.present?
        SettingPreferenceCookie.create!(
          preference_id: setting_pref.id,
          consented: legacy_cookie.consented,
          functional: legacy_cookie.functional,
          performant: legacy_cookie.performant,
          targetable: legacy_cookie.targetable,
          consented_at: legacy_cookie.consented_at,
          consent_version: legacy_cookie.consent_version,
          created_at: legacy_cookie.created_at,
          updated_at: legacy_cookie.updated_at,
        )
      end

      # Migrate language
      legacy_language = legacy_pref.public_send("#{prefix}_preference_language") rescue nil
      if legacy_language.present?
        option_id = map_language_option_id(legacy_language.option_id, preference_type)
        SettingPreferenceLanguage.create!(
          preference_id: setting_pref.id,
          option_id: option_id,
          created_at: legacy_language.created_at,
          updated_at: legacy_language.updated_at,
        )
      end

      # Migrate region
      legacy_region = legacy_pref.public_send("#{prefix}_preference_region") rescue nil
      if legacy_region.present?
        option_id = map_region_option_id(legacy_region.option_id, preference_type)
        SettingPreferenceRegion.create!(
          preference_id: setting_pref.id,
          option_id: option_id,
          created_at: legacy_region.created_at,
          updated_at: legacy_region.updated_at,
        )
      end

      # Migrate timezone
      legacy_timezone = legacy_pref.public_send("#{prefix}_preference_timezone") rescue nil
      if legacy_timezone.present?
        option_id = map_timezone_option_id(legacy_timezone.option_id, preference_type)
        SettingPreferenceTimezone.create!(
          preference_id: setting_pref.id,
          option_id: option_id,
          created_at: legacy_timezone.created_at,
          updated_at: legacy_timezone.updated_at,
        )
      end

      # Migrate colortheme
      legacy_colortheme = legacy_pref.public_send("#{prefix}_preference_colortheme") rescue nil
      return if legacy_colortheme.blank?

      option_id = map_colortheme_option_id(legacy_colortheme.option_id, preference_type)
      SettingPreferenceColortheme.create!(
        preference_id: setting_pref.id,
        option_id: option_id,
        created_at: legacy_colortheme.created_at,
        updated_at: legacy_colortheme.updated_at,
      )
    end

    define_method(:map_status_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_binding_method_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_dbsc_status_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_language_option_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_region_option_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_timezone_option_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:map_colortheme_option_id) do |legacy_id, _preference_type|
      legacy_id
    end

    define_method(:find_replacement_id) do |legacy_replaced_by_id, preference_type|
      return nil if legacy_replaced_by_id.blank?

      # Find the legacy preference that was replaced
      legacy_class =
        case preference_type
        when "AppPreference" then AppPreference
        when "OrgPreference" then OrgPreference
        when "ComPreference" then ComPreference
        end

      return nil if legacy_class.blank?

      legacy_replacement = legacy_class.find_by(id: legacy_replaced_by_id)
      return nil if legacy_replacement.blank?

      # Find the corresponding setting preference
      setting_replacement = SettingPreference.find_by(public_id: legacy_replacement.public_id)
      setting_replacement&.id
    end

    define_method(:verify_preference_match) do |legacy_pref, setting_pref, mismatches|
      issues = []

      issues << "jti mismatch" if legacy_pref.jti != setting_pref.jti
      issues << "token_digest mismatch" if legacy_pref.token_digest != setting_pref.token_digest
      issues << "device_id mismatch" if legacy_pref.device_id != setting_pref.device_id
      issues << "status_id mismatch" if legacy_pref.status_id != setting_pref.status_id

      return unless issues.any?

      mismatches << {
        public_id: legacy_pref.public_id,
        type: legacy_pref.class.name,
        issue: issues.join(", "),
      }
    end
  end
end
