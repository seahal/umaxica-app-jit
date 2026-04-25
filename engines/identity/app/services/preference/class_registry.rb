# typed: false
# frozen_string_literal: true

module Preference
  module ClassRegistry
    module_function

    TYPE_KEY_MAP = {
      :timezone => :timezone,
      :language => :language,
      :region => :region,
      :colortheme => :colortheme,
      "Timezone" => :timezone,
      "Language" => :language,
      "Region" => :region,
      "Colortheme" => :colortheme,
    }.freeze

    # Feature flag: Use setting database for token-like preferences
    # When enabled, uses StorageAdapter for dual-read/write to setting database
    USE_SETTING_DATABASE = ENV.fetch("USE_SETTING_DATABASE", "true") == "true"

    REGISTRY = {
      "App" => {
        preference: USE_SETTING_DATABASE ? SettingPreference : AppPreference,
        legacy_preference: AppPreference,
        status: USE_SETTING_DATABASE ? SettingPreferenceStatus : AppPreferenceStatus,
        cookie: USE_SETTING_DATABASE ? SettingPreferenceCookie : AppPreferenceCookie,
        audit: USE_SETTING_DATABASE ? SettingPreferenceActivity : AppPreferenceActivity,
        audit_event: AppPreferenceActivityEvent,
        audit_level: AppPreferenceActivityLevel,
        option_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezoneOption : AppPreferenceTimezoneOption,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguageOption : AppPreferenceLanguageOption,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegionOption : AppPreferenceRegionOption,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColorthemeOption : AppPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezone : AppPreferenceTimezone,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguage : AppPreferenceLanguage,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegion : AppPreferenceRegion,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColortheme : AppPreferenceColortheme,
        }.freeze,
        owner_type: "User",
      }.freeze,
      "Com" => {
        preference: USE_SETTING_DATABASE ? SettingPreference : ComPreference,
        legacy_preference: ComPreference,
        status: USE_SETTING_DATABASE ? SettingPreferenceStatus : ComPreferenceStatus,
        cookie: USE_SETTING_DATABASE ? SettingPreferenceCookie : ComPreferenceCookie,
        audit: USE_SETTING_DATABASE ? SettingPreferenceActivity : ComPreferenceActivity,
        audit_event: ComPreferenceActivityEvent,
        audit_level: ComPreferenceActivityLevel,
        option_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezoneOption : ComPreferenceTimezoneOption,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguageOption : ComPreferenceLanguageOption,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegionOption : ComPreferenceRegionOption,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColorthemeOption : ComPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezone : ComPreferenceTimezone,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguage : ComPreferenceLanguage,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegion : ComPreferenceRegion,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColortheme : ComPreferenceColortheme,
        }.freeze,
        owner_type: "Customer",
      }.freeze,
      "Org" => {
        preference: USE_SETTING_DATABASE ? SettingPreference : OrgPreference,
        legacy_preference: OrgPreference,
        status: USE_SETTING_DATABASE ? SettingPreferenceStatus : OrgPreferenceStatus,
        cookie: USE_SETTING_DATABASE ? SettingPreferenceCookie : OrgPreferenceCookie,
        audit: USE_SETTING_DATABASE ? SettingPreferenceActivity : OrgPreferenceActivity,
        audit_event: OrgPreferenceActivityEvent,
        audit_level: OrgPreferenceActivityLevel,
        option_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezoneOption : OrgPreferenceTimezoneOption,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguageOption : OrgPreferenceLanguageOption,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegionOption : OrgPreferenceRegionOption,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColorthemeOption : OrgPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: USE_SETTING_DATABASE ? SettingPreferenceTimezone : OrgPreferenceTimezone,
          language: USE_SETTING_DATABASE ? SettingPreferenceLanguage : OrgPreferenceLanguage,
          region: USE_SETTING_DATABASE ? SettingPreferenceRegion : OrgPreferenceRegion,
          colortheme: USE_SETTING_DATABASE ? SettingPreferenceColortheme : OrgPreferenceColortheme,
        }.freeze,
        owner_type: "Staff",
      }.freeze,
      "Jobs" => { alias_of: "Org" }.freeze,
      "Mission_control" => { alias_of: "Org" }.freeze,
      "User" => {
        preference: UserPreference,
        option_classes: {
          timezone: UserPreferenceTimezoneOption,
          language: UserPreferenceLanguageOption,
          region: UserPreferenceRegionOption,
          colortheme: UserPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: UserPreferenceTimezone,
          language: UserPreferenceLanguage,
          region: UserPreferenceRegion,
          colortheme: UserPreferenceColortheme,
        }.freeze,
      }.freeze,
      "Staff" => {
        preference: StaffPreference,
        option_classes: {
          timezone: StaffPreferenceTimezoneOption,
          language: StaffPreferenceLanguageOption,
          region: StaffPreferenceRegionOption,
          colortheme: StaffPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: StaffPreferenceTimezone,
          language: StaffPreferenceLanguage,
          region: StaffPreferenceRegion,
          colortheme: StaffPreferenceColortheme,
        }.freeze,
      }.freeze,
      "Customer" => {
        preference: CustomerPreference,
        option_classes: {
          timezone: CustomerPreferenceTimezoneOption,
          language: CustomerPreferenceLanguageOption,
          region: CustomerPreferenceRegionOption,
          colortheme: CustomerPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: CustomerPreferenceTimezone,
          language: CustomerPreferenceLanguage,
          region: CustomerPreferenceRegion,
          colortheme: CustomerPreferenceColortheme,
        }.freeze,
      }.freeze,
      # Unified setting database entries
      "Setting" => {
        preference: SettingPreference,
        status: SettingPreferenceStatus,
        cookie: SettingPreferenceCookie,
        audit: SettingPreferenceActivity,
        option_classes: {
          timezone: SettingPreferenceTimezoneOption,
          language: SettingPreferenceLanguageOption,
          region: SettingPreferenceRegionOption,
          colortheme: SettingPreferenceColorthemeOption,
        }.freeze,
        record_classes: {
          timezone: SettingPreferenceTimezone,
          language: SettingPreferenceLanguage,
          region: SettingPreferenceRegion,
          colortheme: SettingPreferenceColortheme,
        }.freeze,
      }.freeze,
    }.freeze

    def fetch(prefix)
      entry =
        REGISTRY.fetch(prefix) do
          raise KeyError, "Unknown preference prefix: #{prefix.inspect}"
        end
      entry.key?(:alias_of) ? fetch(entry[:alias_of]) : entry
    end

    def for_controller_path(controller_path)
      segments = controller_path.to_s.split("/")
      # Handle namespaced engine controllers (e.g., jit/identity/sign/app/...)
      segments.shift(2) if segments[0] == "jit"

      prefix = segments[1]&.capitalize
      entry = fetch(prefix)
      entry[:legacy_preference] || entry[:preference]
    end

    def prefix_from_preference_class(preference_class)
      preference_class.name.delete_suffix("Preference")
    end

    def status_class_for(preference_class)
      fetch(prefix_from_preference_class(preference_class))[:status]
    end

    def audit_class_for(preference_class)
      fetch(prefix_from_preference_class(preference_class))[:audit]
    end

    def audit_event_class_for(preference_class)
      fetch(prefix_from_preference_class(preference_class))[:audit_event]
    end

    def audit_level_class_for(preference_class)
      fetch(prefix_from_preference_class(preference_class))[:audit_level]
    end

    def cookie_class(prefix)
      fetch(prefix)[:cookie]
    end

    def option_class(prefix, type)
      fetch(prefix)[:option_classes].fetch(TYPE_KEY_MAP.fetch(type))
    end

    def record_class(prefix, type)
      fetch(prefix)[:record_classes].fetch(TYPE_KEY_MAP.fetch(type))
    end

    # Returns true if using the unified setting database for token-like preferences
    def use_setting_database?
      USE_SETTING_DATABASE
    end

    # Returns the StorageAdapter class for unified preference storage
    def storage_adapter
      Preference::StorageAdapter
    end

    # Returns the legacy preference class for the given preference type
    def legacy_preference_class(preference_type)
      prefix = preference_type.to_s.delete_suffix("Preference")
      fetch(prefix)[:legacy_preference]
    end

    # Returns the owner type (User, Staff, Customer) for a preference type
    def owner_type_for(preference_type)
      prefix = preference_type.to_s.delete_suffix("Preference")
      fetch(prefix)[:owner_type]
    end

    # Ensure default reference records exist across all preference databases
    def ensure_all_defaults!
      # Legacy defaults
      %w(App Com Org).each do |prefix|
        ensure_legacy_defaults!(prefix)
      end

      # Setting database defaults
      storage_adapter.ensure_setting_defaults! if use_setting_database?
    end

    private

    def ensure_legacy_defaults!(prefix)
      entry = fetch(prefix)

      entry[:status].ensure_defaults! if entry[:status].respond_to?(:ensure_defaults!)

      if entry[:preference].respond_to?(:dbsc_binding_method_class)
        entry[:preference].dbsc_binding_method_class.ensure_defaults!
      end

      if entry[:preference].respond_to?(:dbsc_status_class)
        entry[:preference].dbsc_status_class.ensure_defaults!
      end

      entry[:option_classes].each_value do |klass|
        klass.ensure_defaults! if klass.respond_to?(:ensure_defaults!)
      end
    rescue KeyError
      # Skip if prefix not found
    end
  end
end
