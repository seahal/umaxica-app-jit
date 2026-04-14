# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class StorageAdapterTest < ActiveSupport::TestCase
    setup do
      StorageAdapter.ensure_setting_defaults!
      ensure_legacy_defaults!
    end

    test "ensure_setting_defaults! restores missing status rows in readonly mode" do
      SettingRecord.connected_to(role: :writing) do
        SettingPreferenceStatus.where(id: SettingPreferenceStatus::DEFAULTS).delete_all
      end

      SettingRecord.connected_to(role: :reading) do
        assert_nothing_raised do
          StorageAdapter.ensure_setting_defaults!
        end
      end

      assert_equal SettingPreferenceStatus::DEFAULTS, SettingPreferenceStatus.order(:id).pluck(:id)
    end

    def ensure_legacy_defaults!
      AppPreferenceStatus.ensure_defaults!
      AppPreferenceBindingMethod.ensure_defaults!
      AppPreferenceDbscStatus.ensure_defaults!
      AppPreferenceLanguageOption.ensure_defaults!
      AppPreferenceRegionOption.ensure_defaults!
      AppPreferenceTimezoneOption.ensure_defaults!
      AppPreferenceColorthemeOption.ensure_defaults!

      OrgPreferenceStatus.ensure_defaults!
      OrgPreferenceBindingMethod.ensure_defaults!
      OrgPreferenceDbscStatus.ensure_defaults!
      OrgPreferenceLanguageOption.ensure_defaults!
      OrgPreferenceRegionOption.ensure_defaults!
      OrgPreferenceTimezoneOption.ensure_defaults!
      OrgPreferenceColorthemeOption.ensure_defaults!

      ComPreferenceStatus.ensure_defaults!
      ComPreferenceBindingMethod.ensure_defaults!
      ComPreferenceDbscStatus.ensure_defaults!
      ComPreferenceLanguageOption.ensure_defaults!
      ComPreferenceRegionOption.ensure_defaults!
      ComPreferenceTimezoneOption.ensure_defaults!
    end

    # ============================================================================
    # Setting database tests (new unified schema)
    # ============================================================================

    test "find_by_public_id returns wrapper from setting database" do
      setting_pref = SettingPreference.create!(
        owner_type: "User",
        owner_id: 1,
        jti: SecureRandom.uuid,
      )

      wrapper = StorageAdapter.find_by_public_id(setting_pref.public_id, preference_type: "AppPreference")

      assert_not_nil wrapper
      assert_equal setting_pref.public_id, wrapper.public_id
      assert_equal :setting, wrapper.source
    end

    test "find_by_public_id falls back to legacy when not in setting" do
      legacy_pref = create_legacy_app_preference

      wrapper = StorageAdapter.find_by_public_id(legacy_pref.public_id, preference_type: "AppPreference")

      assert_not_nil wrapper
      assert_equal legacy_pref.public_id, wrapper.public_id
      assert_equal :legacy, wrapper.source
    end

    test "create! creates preference in setting database" do
      wrapper = StorageAdapter.create!(
        { jti: SecureRandom.uuid, owner_id: 1 },
        preference_type: "AppPreference",
      )

      assert_not_nil wrapper
      assert_equal :setting, wrapper.source
      assert_equal "User", wrapper.owner_type

      # Verify it exists in setting database
      setting_pref = SettingPreference.find_by(public_id: wrapper.public_id)

      assert_not_nil setting_pref
    end

    test "create! reuses existing setting preference for the same owner" do
      first = StorageAdapter.create!(
        { jti: SecureRandom.uuid, owner_id: 0 },
        preference_type: "ComPreference",
      )

      assert_no_difference("SettingPreference.count") do
        second = StorageAdapter.create!(
          { jti: SecureRandom.uuid, owner_id: 0 },
          preference_type: "ComPreference",
        )

        assert_equal first.public_id, second.public_id
      end
    end

    test "preference wrapper delegates methods to underlying preference" do
      setting_pref = SettingPreference.create!(
        owner_type: "User",
        owner_id: 1,
        jti: SecureRandom.uuid,
      )

      # Test wrapper through the public find_by_public_id interface
      wrapper = StorageAdapter.find_by_public_id(setting_pref.public_id, preference_type: "AppPreference")

      assert_not_nil wrapper
      assert_equal setting_pref.id, wrapper.id
      assert_equal setting_pref.public_id, wrapper.public_id
      assert_equal setting_pref.jti, wrapper.jti
      assert_equal setting_pref.status_id, wrapper.status_id
      assert_predicate wrapper, :persisted?
    end

    test "preference wrapper provides DBSC status methods" do
      setting_pref = SettingPreference.create!(
        owner_type: "User",
        owner_id: 1,
        jti: SecureRandom.uuid,
        dbsc_status_id: SettingPreferenceDbscStatus::NOTHING,
        binding_method_id: SettingPreferenceBindingMethod::NOTHING,
      )

      wrapper = StorageAdapter.find_by_public_id(setting_pref.public_id, preference_type: "AppPreference")

      assert_not_nil wrapper
      assert_predicate wrapper, :dbsc_status_nothing?
      assert_predicate wrapper, :binding_method_nothing?
      assert_not_predicate wrapper, :dbsc_enabled?
    end

    test "preference wrapper builds correct JWT payload" do
      setting_pref = create_setting_preference_with_children

      wrapper = StorageAdapter.find_by_public_id(setting_pref.public_id, preference_type: "AppPreference")

      assert_not_nil wrapper

      payload = wrapper.build_payload

      assert_equal "ja", payload["lx"]
      assert_equal "jp", payload["ri"]
      assert_equal "Asia/Tokyo", payload["tz"]
      assert_predicate payload["ct"], :present?
      assert_includes [true, false], payload["consented"]
    end

    test "find_by_public_id returns nil for non-existent public_id" do
      result = StorageAdapter.find_by_public_id("non_existent_id", preference_type: "AppPreference")

      assert_nil result
    end

    test "find_by_token_digest returns nil for non-existent token" do
      result = StorageAdapter.find_by_token_digest(
        SHA3::Digest::SHA3_384.digest("non_existent"),
        preference_type: "AppPreference",
      )

      assert_nil result
    end

    test "option_class returns setting option classes" do
      assert_equal SettingPreferenceLanguageOption, StorageAdapter.option_class("AppPreference", :language)
      assert_equal SettingPreferenceRegionOption, StorageAdapter.option_class("AppPreference", :region)
      assert_equal SettingPreferenceTimezoneOption, StorageAdapter.option_class("AppPreference", :timezone)
      assert_equal SettingPreferenceColorthemeOption, StorageAdapter.option_class("AppPreference", :colortheme)
    end

    test "record_class returns setting record classes" do
      assert_equal SettingPreferenceLanguage, StorageAdapter.record_class("AppPreference", :language)
      assert_equal SettingPreferenceRegion, StorageAdapter.record_class("AppPreference", :region)
      assert_equal SettingPreferenceTimezone, StorageAdapter.record_class("AppPreference", :timezone)
      assert_equal SettingPreferenceColortheme, StorageAdapter.record_class("AppPreference", :colortheme)
      assert_equal SettingPreferenceCookie, StorageAdapter.record_class("AppPreference", :cookie)
    end

    # ============================================================================
    # Dual-read fallback tests
    # ============================================================================

    test "find_by_token_digest finds from setting database first" do
      setting_pref = SettingPreference.create!(
        owner_type: "User",
        owner_id: 1,
        jti: SecureRandom.uuid,
        token_digest: SHA3::Digest::SHA3_384.digest("test_verifier"),
      )

      wrapper = StorageAdapter.find_by_token_digest(
        setting_pref.token_digest,
        preference_type: "AppPreference",
      )

      assert_not_nil wrapper
      assert_equal :setting, wrapper.source
    end

    test "owner_type maps preference types correctly" do
      app_wrapper = StorageAdapter.create!({ owner_id: 1 }, preference_type: "AppPreference")

      assert_equal "User", app_wrapper.owner_type

      org_wrapper = StorageAdapter.create!({ owner_id: 1 }, preference_type: "OrgPreference")

      assert_equal "Staff", org_wrapper.owner_type

      com_wrapper = StorageAdapter.create!({ owner_id: 1 }, preference_type: "ComPreference")

      assert_equal "Customer", com_wrapper.owner_type
    end

    private

    def create_legacy_app_preference
      expires_at = 400.days.from_now
      AppPreference.create!(
        expires_at: expires_at,
        jti: Jit::Security::Jwt::JtiGenerator.generate,
      )
    end

    def create_setting_preference_with_children
      setting_pref = SettingPreference.create!(
        owner_type: "User",
        owner_id: 1,
        jti: SecureRandom.uuid,
      )

      SettingPreferenceCookie.create!(
        preference: setting_pref,
        consented: false,
        functional: false,
        performant: false,
        targetable: false,
      )

      SettingPreferenceLanguage.create!(
        preference: setting_pref,
        option_id: SettingPreferenceLanguageOption::JA,
      )

      SettingPreferenceRegion.create!(
        preference: setting_pref,
        option_id: SettingPreferenceRegionOption::JP,
      )

      SettingPreferenceTimezone.create!(
        preference: setting_pref,
        option_id: SettingPreferenceTimezoneOption::ASIA_TOKYO,
      )

      SettingPreferenceColortheme.create!(
        preference: setting_pref,
        option_id: SettingPreferenceColorthemeOption::SYSTEM,
      )

      setting_pref.reload
    end
  end
end
