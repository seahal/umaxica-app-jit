# typed: false
# frozen_string_literal: true

module Preference
  # Storage adapter that provides dual-read and dual-write capabilities
  # during the migration from legacy preference tables (AppPreference, OrgPreference, ComPreference)
  # to the unified SettingPreference in the setting database.
  #
  # Read strategy:
  #   - Try setting database first
  #   - Fall back to legacy tables if not found
  #
  # Write strategy:
  #   - Write to both setting and legacy tables (dual-write)
  #   - Setting database is the source of truth
  class StorageAdapter
    class << self
      # Find preference by public_id with dual-read fallback
      def find_by_public_id(public_id, preference_type:)
        return nil if public_id.blank?

        # Try setting database first
        setting_pref = SettingPreference.find_by(public_id: public_id)
        return wrap_setting_preference(setting_pref, preference_type) if setting_pref.present?

        # Fall back to legacy table during migration
        legacy_pref = legacy_find_by_public_id(public_id, preference_type)
        return nil if legacy_pref.blank?

        wrap_legacy_preference(legacy_pref, preference_type)
      end

      # Find preference by token_digest with dual-read fallback
      def find_by_token_digest(token_digest, preference_type:)
        return nil if token_digest.blank?

        # Try setting database first
        setting_pref = SettingPreference.find_by(token_digest: token_digest)
        return wrap_setting_preference(setting_pref, preference_type) if setting_pref.present?

        # Fall back to legacy table
        legacy_class = legacy_class_for(preference_type)
        return nil if legacy_class.blank?

        legacy_pref = legacy_class.find_by(token_digest: token_digest)
        return nil if legacy_pref.blank?

        wrap_legacy_preference(legacy_pref, preference_type)
      end

      # Create new preference with dual-write
      def create!(attrs, preference_type:)
        owner_type = owner_type_from_preference_type(preference_type)
        setting_attrs = attrs.merge(owner_type: owner_type, owner_id: attrs[:owner_id] || 0)

        SettingRecord.connected_to(role: :writing) do
          SettingPreference.transaction do
            setting_pref =
              SettingPreference.find_or_create_by!(
                owner_type: setting_attrs[:owner_type],
                owner_id: setting_attrs[:owner_id],
              ) do |record|
                record.assign_attributes(setting_attrs.except(:owner_type, :owner_id))
              end

            # Also create in legacy table during dual-write period
            begin
              create_legacy_preference!(setting_pref, attrs, preference_type)
            rescue StandardError => e
              Rails.event.record(
                "preference.storage_adapter.legacy_create_failed",
                error: e.class.name,
                message: e.message,
                public_id: setting_pref.public_id,
                preference_type: preference_type,
              )
              # Don't fail the whole operation if legacy write fails
            end

            wrap_setting_preference(setting_pref, preference_type)
          end
        end
      end

      # Rotate token with dual-write
      def rotate!(presented_digest:, device_id:, preference_type:, now: Time.current)
        # Try to rotate in setting database first
        setting_pref = find_setting_by_token_digest(presented_digest)

        if setting_pref.present?
          rotated = rotate_setting_preference!(
            setting_pref, presented_digest: presented_digest, device_id: device_id,
                          now: now,
          )
          # Also rotate legacy if exists
          rotate_legacy_if_exists!(rotated, preference_type)
          return wrap_setting_preference(rotated, preference_type)
        end

        # Fall back to legacy rotation during migration
        legacy_result = rotate_legacy!(
          presented_digest: presented_digest, device_id: device_id,
          preference_type: preference_type, now: now,
        )
        return nil if legacy_result.blank?

        wrap_legacy_preference(legacy_result, preference_type)
      end

      # Consume token once with dual-write tracking
      def consume_once_by_digest!(digest:, preference_type:, now: Time.current)
        return nil if digest.blank?

        # Try setting database first
        setting_pref = find_setting_by_token_digest(digest)
        if setting_pref.present?
          consumed = consume_setting_once!(setting_pref, digest: digest, now: now)
          # Mark legacy as consumed if exists
          mark_legacy_consumed_if_exists!(consumed, preference_type, now) if consumed.present?
          return wrap_setting_preference(consumed, preference_type)
        end

        # Fall back to legacy
        legacy_class = legacy_class_for(preference_type)
        return nil if legacy_class.blank?

        legacy_pref = legacy_class.consume_once_by_digest!(digest: digest, now: now)
        return nil if legacy_pref.blank?

        wrap_legacy_preference(legacy_pref, preference_type)
      end

      # Build payload from preference (works with both setting and legacy)
      def build_payload(preference_wrapper)
        preference_wrapper.build_payload
      end

      # Get option class for preference type and option type
      def option_class(preference_type, option_type)
        # Use setting option classes
        case option_type.to_sym
        when :language
          SettingPreferenceLanguageOption
        when :region
          SettingPreferenceRegionOption
        when :timezone
          SettingPreferenceTimezoneOption
        when :colortheme
          SettingPreferenceColorthemeOption
        else
          legacy_option_class(preference_type, option_type)
        end
      end

      # Get record class for preference type and option type
      def record_class(preference_type, option_type)
        case option_type.to_sym
        when :language
          SettingPreferenceLanguage
        when :region
          SettingPreferenceRegion
        when :timezone
          SettingPreferenceTimezone
        when :colortheme
          SettingPreferenceColortheme
        when :cookie
          SettingPreferenceCookie
        else
          legacy_record_class(preference_type, option_type)
        end
      end

      # Ensure default reference records exist in setting database
      def ensure_setting_defaults!
        SettingRecord.connected_to(role: :writing) do
          SettingPreferenceStatus.ensure_defaults!
          SettingPreferenceBindingMethod.ensure_defaults!
          SettingPreferenceDbscStatus.ensure_defaults!
          SettingPreferenceLanguageOption.ensure_defaults!
          SettingPreferenceRegionOption.ensure_defaults!
          SettingPreferenceTimezoneOption.ensure_defaults!
          SettingPreferenceColorthemeOption.ensure_defaults!
        end
      end

      private

      def owner_type_from_preference_type(preference_type)
        case preference_type.to_s
        when "OrgPreference" then "Staff"
        when "ComPreference" then "Customer"
        else "User"
        end
      end

      def find_setting_by_token_digest(token_digest)
        SettingPreference.find_by(token_digest: token_digest)
      end

      def legacy_find_by_public_id(public_id, preference_type)
        legacy_class = legacy_class_for(preference_type)
        return nil if legacy_class.blank?

        legacy_class.find_by(public_id: public_id)
      end

      def legacy_class_for(preference_type)
        case preference_type.to_s
        when "AppPreference" then AppPreference
        when "OrgPreference" then OrgPreference
        when "ComPreference" then ComPreference
        end
      end

      def wrap_setting_preference(setting_pref, preference_type)
        return nil if setting_pref.blank?

        PreferenceWrapper.new(
          preference: setting_pref,
          source: :setting,
          preference_type: preference_type,
        )
      end

      def wrap_legacy_preference(legacy_pref, preference_type)
        return nil if legacy_pref.blank?

        PreferenceWrapper.new(
          preference: legacy_pref,
          source: :legacy,
          preference_type: preference_type,
        )
      end

      def create_legacy_preference!(setting_pref, attrs, preference_type)
        legacy_class = legacy_class_for(preference_type)
        return if legacy_class.blank?

        legacy_attrs = attrs.except(:owner_type, :owner_id).merge(
          public_id: setting_pref.public_id,
          jti: setting_pref.jti,
          token_digest: setting_pref.token_digest,
          device_id: setting_pref.device_id,
          device_id_digest: setting_pref.device_id_digest,
          binding_method_id: setting_pref.binding_method_id,
          dbsc_status_id: setting_pref.dbsc_status_id,
          dbsc_session_id: setting_pref.dbsc_session_id,
          status_id: setting_pref.status_id,
          expires_at: setting_pref.expires_at,
        )

        legacy_class.find_or_create_by!(public_id: setting_pref.public_id) do |record|
          record.assign_attributes(legacy_attrs.except(:public_id))
        end
      end

      def rotate_setting_preference!(setting_pref, presented_digest:, device_id:, now:)
        SettingRecord.connected_to(role: :writing) do
          SettingPreference.transaction do
            consumed = consume_setting_once!(setting_pref, digest: presented_digest, now: now)
            return nil if consumed.blank?

            rotate_setting_record!(consumed, device_id: device_id, now: now)
            consumed
          end
        end
      end

      def rotate_legacy!(presented_digest:, device_id:, preference_type:, now:)
        legacy_class = legacy_class_for(preference_type)
        return nil if legacy_class.blank?

        legacy_class.rotate!(presented_digest: presented_digest, device_id: device_id, now: now)
      end

      def rotate_legacy_if_exists!(setting_pref, preference_type)
        legacy_class = legacy_class_for(preference_type)
        return if legacy_class.blank?

        legacy_pref = legacy_class.find_by(public_id: setting_pref.public_id)
        return if legacy_pref.blank?

        # Mark legacy as replaced
        legacy_pref.update!(replaced_by_id: setting_pref.id)
      rescue StandardError => e
        Rails.event.record(
          "preference.storage_adapter.legacy_rotate_failed",
          error: e.class.name,
          message: e.message,
          public_id: setting_pref.public_id,
        )
      end

      def consume_setting_once!(setting_pref, digest:, now:)
        return nil if digest.blank?

        consumed_at = now
        return nil unless setting_pref.token_digest.present? &&
          ActiveSupport::SecurityUtils.secure_compare(setting_pref.token_digest, digest) &&
          setting_pref.used_at.nil? &&
          setting_pref.revoked_at.nil? &&
          setting_pref.compromised_at.nil? &&
          (setting_pref.expires_at.nil? || setting_pref.expires_at > consumed_at)

        setting_pref.update!(used_at: consumed_at, updated_at: consumed_at)
        setting_pref
      end

      def mark_legacy_consumed_if_exists!(setting_pref, preference_type, now)
        legacy_class = legacy_class_for(preference_type)
        return if legacy_class.blank?

        legacy_pref = legacy_class.find_by(public_id: setting_pref.public_id)
        return if legacy_pref.blank?

        legacy_pref.update!(used_at: now, updated_at: now)
      rescue StandardError => e
        Rails.event.record(
          "preference.storage_adapter.legacy_consume_failed",
          error: e.class.name,
          message: e.message,
          public_id: setting_pref.public_id,
        )
      end

      def rotate_setting_record!(consumed, device_id:, now:)
        new_device_id = device_id.presence || consumed.device_id
        attrs = {
          status_id: consumed.status_id,
          device_id: new_device_id,
          device_id_digest: digest_device_id(new_device_id),
          expires_at: now + 400.days,
          jti: Jit::Security::Jwt::JtiGenerator.generate,
          binding_method_id: consumed.binding_method_id,
          dbsc_status_id: consumed.dbsc_status_id,
          dbsc_session_id: consumed.dbsc_session_id,
          dbsc_public_key: consumed.dbsc_public_key,
          dbsc_challenge: consumed.dbsc_challenge,
          dbsc_challenge_issued_at: consumed.dbsc_challenge_issued_at,
          used_at: nil,
          replaced_by_id: nil,
        }

        consumed.update!(attrs)
        raw_refresh_token, verifier = generate_refresh_token_pair(public_id: consumed.public_id)
        consumed.update!(token_digest: digest_refresh_token(verifier))
        consumed.issued_refresh_token = raw_refresh_token
        consumed
      end

      def migrate_setting_preference_children!(from:, to:)
        %w(cookie region timezone language colortheme).each do |suffix|
          association_name = "setting_preference_#{suffix}"
          next unless from.respond_to?(association_name)

          child = from.public_send(association_name)
          next unless child&.respond_to?(:preference_id)

          # Create new child record for the replacement preference
          child_attrs = child.attributes.except("id", "created_at", "updated_at", "preference_id")
          child_class = child.class
          child_class.create!(child_attrs.merge(preference_id: to.id))
        end
      end

      def generate_refresh_token_for(preference)
        public_id = preference.public_id
        verifier = SecureRandom.urlsafe_base64(48)
        "#{public_id}.#{verifier}"
      end

      def generate_refresh_token_pair(public_id:)
        verifier = SecureRandom.urlsafe_base64(48)
        ["#{public_id}.#{verifier}", verifier]
      end

      def digest_refresh_token(verifier)
        SHA3::Digest::SHA3_384.digest(verifier.to_s)
      end

      def digest_device_id(device_id)
        return nil if device_id.blank?

        Base64.strict_encode64(SHA3::Digest::SHA3_384.digest(device_id.to_s))
      end

      def legacy_option_class(preference_type, option_type)
        Preference::ClassRegistry.option_class(
          preference_type.to_s.delete_suffix("Preference"),
          option_type,
        )
      end

      def legacy_record_class(preference_type, option_type)
        Preference::ClassRegistry.record_class(
          preference_type.to_s.delete_suffix("Preference"),
          option_type,
        )
      end
    end

    # Wrapper class that provides a unified interface over both
    # SettingPreference (new) and legacy preference models (AppPreference, etc.)
    class PreferenceWrapper
      attr_reader :preference, :source, :preference_type

      def initialize(preference:, source:, preference_type:)
        @preference = preference
        @source = source
        @preference_type = preference_type
      end

      # Delegate common methods to the underlying preference
      delegate :id, to: :@preference

      delegate :public_id, to: :@preference

      delegate :jti, to: :@preference

      delegate :token_digest, to: :@preference

      delegate :device_id, to: :@preference

      delegate :device_id_digest, to: :@preference

      delegate :expires_at, to: :@preference

      delegate :status_id, to: :@preference

      delegate :binding_method_id, to: :@preference

      delegate :dbsc_status_id, to: :@preference

      delegate :dbsc_session_id, to: :@preference

      delegate :dbsc_challenge, to: :@preference

      delegate :dbsc_challenge_issued_at, to: :@preference

      delegate :dbsc_public_key, to: :@preference

      delegate :replaced_by_id, to: :@preference

      delegate :used_at, to: :@preference

      delegate :revoked_at, to: :@preference

      delegate :compromised_at, to: :@preference

      delegate :updated_at, to: :@preference

      def owner_type
        return @preference.owner_type if @source == :setting

        # Map legacy preference types to owner types
        case @preference_type.to_s
        when "AppPreference" then "User"
        when "OrgPreference" then "Staff"
        when "ComPreference" then "Customer"
        end
      end

      def owner_id
        @preference.owner_id if @source == :setting
      end

      delegate :persisted?, to: :@preference

      def reload
        @preference.reload
        self
      end

      def update!(attrs)
        SettingRecord.connected_to(role: :writing) do
          SettingPreference.transaction do
            # Update setting database first
            if @source == :setting
              @preference.update!(attrs)
            end

            # Also update legacy during dual-write period
            update_legacy_if_exists!(attrs)
          end
        end
      end

      def replay?
        @preference.used_at.present?
      end

      def revoked?
        @preference.revoked_at.present? || @preference.compromised_at.present?
      end

      def binding_method_nothing?
        binding_method_value == 0
      end

      def binding_method_dbsc?
        binding_method_value == 1
      end

      def binding_method_legacy?
        binding_method_value == 2
      end

      def dbsc_status_nothing?
        dbsc_status_value == 0
      end

      def dbsc_status_pending?
        dbsc_status_value == SettingPreferenceDbscStatus::PENDING
      end

      def dbsc_status_active?
        dbsc_status_value == SettingPreferenceDbscStatus::ACTIVE
      end

      def dbsc_status_failed?
        dbsc_status_value == SettingPreferenceDbscStatus::FAILED
      end

      def dbsc_status_revoke?
        dbsc_status_value == SettingPreferenceDbscStatus::REVOKE
      end

      def dbsc_enabled?
        binding_method_dbsc?
      end

      # Access child associations with unified interface
      def preference_cookie
        child_record("cookie")
      end

      def preference_language
        child_record("language")
      end

      def preference_region
        child_record("region")
      end

      def preference_timezone
        child_record("timezone")
      end

      def preference_colortheme
        child_record("colortheme")
      end

      # Build JWT payload from preference
      def build_payload
        language = preference_language&.option_id
        region = preference_region&.option_id
        timezone = preference_timezone&.option_id
        colortheme = preference_colortheme&.option_id
        consent_state = cookie_consent_state

        prefix = @preference_type.to_s.delete_suffix("Preference")

        {
          "lx" => option_id_to_language(language, prefix) || "ja",
          "ri" => option_id_to_region(region, prefix) || "jp",
          "tz" => option_id_to_timezone(timezone, prefix) || "Asia/Tokyo",
          "ct" => normalize_colortheme(option_id_to_colortheme(colortheme, prefix)) || "sy",
          "consented" => consent_state[:consented],
          "functional" => consent_state[:functional],
          "performant" => consent_state[:performant],
          "targetable" => consent_state[:targetable],
        }
      end

      delegate :issued_refresh_token, to: :@preference

      delegate :issued_refresh_token=, to: :@preference

      delegate :class, to: :@preference

      def is_a?(klass)
        @preference.is_a?(klass) || super
      end

      def kind_of?(klass)
        is_a?(klass)
      end

      def respond_to?(method_name, include_private = false)
        @preference.respond_to?(method_name, include_private) || super
      end

      def method_missing(method_name, *, &)
        if @preference.respond_to?(method_name)
          @preference.public_send(method_name, *, &)
        else
          super
        end
      end

      private

      def child_record(suffix)
        if @source == :setting
          association_name = "setting_preference_#{suffix}"
          @preference.public_send(association_name) if @preference.respond_to?(association_name)
        else
          association_name = "#{@preference.class.name.underscore}_#{suffix}"
          @preference.public_send(association_name) if @preference.respond_to?(association_name)
        end
      end

      def cookie_consent_state
        cookie = preference_cookie
        return { consented: false, functional: false, performant: false, targetable: false } if cookie.blank?

        {
          consented: !!cookie.consented,
          functional: !!cookie.functional,
          performant: !!cookie.performant,
          targetable: !!cookie.targetable,
        }
      rescue NoMethodError
        { consented: false, functional: false, performant: false, targetable: false }
      end

      def option_id_to_language(option_id, prefix)
        return if option_id.blank?

        return "ja" if option_id == SettingPreferenceLanguageOption::JA
        return "en" if option_id == SettingPreferenceLanguageOption::EN

        option_id.to_s.downcase
      end

      def option_id_to_region(option_id, prefix)
        return if option_id.blank?

        return "jp" if option_id == SettingPreferenceRegionOption::JP
        return "us" if option_id == SettingPreferenceRegionOption::US

        option_id.to_s.downcase
      end

      def option_id_to_timezone(option_id, prefix)
        return if option_id.blank?

        return "Asia/Tokyo" if option_id == SettingPreferenceTimezoneOption::ASIA_TOKYO
        return "Etc/UTC" if option_id == SettingPreferenceTimezoneOption::ETC_UTC

        option_id.to_s
      end

      def option_id_to_colortheme(option_id, prefix)
        return if option_id.blank?

        return "light" if option_id == SettingPreferenceColorthemeOption::LIGHT
        return "dark" if option_id == SettingPreferenceColorthemeOption::DARK
        return "system" if option_id == SettingPreferenceColorthemeOption::SYSTEM

        option_id.to_s
      end

      def normalize_colortheme(value)
        return nil if value.blank?

        theme = value.to_s.downcase
        short_map = { "light" => "li", "dark" => "dr", "system" => "sy" }

        if short_map.value?(theme)
          theme
        else
          short_map[theme]
        end
      end

      def binding_method_value
        @preference.binding_method_id
      end

      def dbsc_status_value
        @preference.dbsc_status_id
      end

      def update_legacy_if_exists!(attrs)
        legacy_class = legacy_class_for(@preference_type)
        return if legacy_class.blank?

        legacy_pref = legacy_class.find_by(public_id: @preference.public_id)
        return if legacy_pref.blank?

        legacy_attrs = attrs.except(:owner_type, :owner_id)
        legacy_pref.update!(legacy_attrs)
      rescue StandardError => e
        Rails.event.record(
          "preference.storage_adapter.legacy_update_failed",
          error: e.class.name,
          message: e.message,
          public_id: @preference.public_id,
        )
      end

      def legacy_class_for(preference_type)
        case preference_type.to_s
        when "AppPreference" then AppPreference
        when "OrgPreference" then OrgPreference
        when "ComPreference" then ComPreference
        end
      end
    end
  end
end
