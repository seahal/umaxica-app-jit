# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preferences
# Database name: setting
#
#  id                       :bigint           not null, primary key
#  compromised_at           :datetime
#  dbsc_challenge           :text
#  dbsc_challenge_issued_at :datetime
#  dbsc_public_key          :jsonb
#  deletable_at             :datetime
#  device_id_digest         :string
#  expires_at               :datetime
#  jti                      :string
#  owner_type               :string           not null
#  revoked_at               :datetime
#  shreddable_at            :datetime
#  token_digest             :binary
#  used_at                  :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  binding_method_id        :bigint           default(0), not null
#  dbsc_session_id          :string
#  dbsc_status_id           :bigint           default(0), not null
#  device_id                :string
#  owner_id                 :bigint           not null
#  public_id                :string           not null
#  replaced_by_id           :bigint
#  status_id                :bigint           default(0), not null
#
# Indexes
#
#  index_settings_preferences_on_binding_method_id        (binding_method_id)
#  index_settings_preferences_on_dbsc_session_id          (dbsc_session_id) UNIQUE
#  index_settings_preferences_on_dbsc_status_id           (dbsc_status_id)
#  index_settings_preferences_on_deletable_at             (deletable_at)
#  index_settings_preferences_on_device_id                (device_id)
#  index_settings_preferences_on_device_id_digest         (device_id_digest)
#  index_settings_preferences_on_jti                      (jti) UNIQUE
#  index_settings_preferences_on_owner_and_status         (owner_type,owner_id,status_id)
#  index_settings_preferences_on_owner_type_and_owner_id  (owner_type,owner_id) UNIQUE
#  index_settings_preferences_on_public_id                (public_id) UNIQUE
#  index_settings_preferences_on_replaced_by_id           (replaced_by_id)
#  index_settings_preferences_on_revoked_at               (revoked_at)
#  index_settings_preferences_on_shreddable_at            (shreddable_at)
#  index_settings_preferences_on_status_id                (status_id)
#  index_settings_preferences_on_token_digest             (token_digest)
#  index_settings_preferences_on_used_at                  (used_at)
#
# Foreign Keys
#
#  fk_rails_...                                  (replaced_by_id => settings_preferences.id) ON DELETE => nullify
#  fk_settings_preferences_on_binding_method_id  (binding_method_id => settings_preference_binding_methods.id)
#  fk_settings_preferences_on_dbsc_status_id     (dbsc_status_id => settings_preference_dbsc_statuses.id)
#  fk_settings_preferences_on_status_id          (status_id => settings_preference_statuses.id)
#
require "test_helper"

class SettingPreferenceTest < ActiveSupport::TestCase
  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
  end

  def build_preference(**attrs)
    SettingPreference.new(
      owner_type: "User",
      owner_id: 1,
      **attrs,
    )
  end

  test "generates public_id on create" do
    preference = SettingPreference.create!(owner_type: "User", owner_id: 1)

    assert_not_nil preference.public_id
    assert_equal 21, preference.public_id.length
  end

  test "requires owner_type" do
    preference = build_preference(owner_type: nil)

    assert_not preference.valid?
    assert_includes preference.errors[:owner_type], "を入力してください"
  end

  test "requires owner_id" do
    preference = build_preference(owner_id: nil)

    assert_not preference.valid?
    assert_includes preference.errors[:owner_id], "を入力してください"
  end

  test "enforces unique owner per owner type" do
    SettingPreference.create!(owner_type: "User", owner_id: 999)

    duplicate = build_preference(owner_type: "User", owner_id: 999)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "allows same owner_id with different owner_type" do
    SettingPreference.create!(owner_type: "User", owner_id: 42)

    assert_nothing_raised do
      SettingPreference.create!(owner_type: "Staff", owner_id: 42)
    end
  end

  test "defaults status_id to NOTHING" do
    preference = SettingPreference.new

    assert_equal SettingPreferenceStatus::NOTHING, preference.status_id
  end

  test "defaults binding_method_id to NOTHING" do
    preference = SettingPreference.new

    assert_equal SettingPreferenceBindingMethod::NOTHING, preference.binding_method_id
  end

  test "defaults dbsc_status_id to NOTHING" do
    preference = SettingPreference.new

    assert_equal SettingPreferenceDbscStatus::NOTHING, preference.dbsc_status_id
  end

  test "scope deletable returns preferences with deletable_at in the past" do
    past   = SettingPreference.create!(owner_type: "User", owner_id: 2, deletable_at: 1.hour.ago)
    future = SettingPreference.create!(owner_type: "User", owner_id: 3, deletable_at: 1.hour.from_now)

    assert_includes SettingPreference.deletable, past
    assert_not_includes SettingPreference.deletable, future
  end

  test "scope shreddable returns preferences with shreddable_at in the past" do
    past   = SettingPreference.create!(owner_type: "User", owner_id: 4, shreddable_at: 1.hour.ago)
    future = SettingPreference.create!(owner_type: "User", owner_id: 5, shreddable_at: 1.hour.from_now)

    assert_includes SettingPreference.shreddable, past
    assert_not_includes SettingPreference.shreddable, future
  end

  test "has_one associations are defined" do
    %i(setting_preference_cookie setting_preference_language setting_preference_region
       setting_preference_timezone setting_preference_colortheme).each do |assoc|
      assert_not_nil SettingPreference.reflect_on_association(assoc),
                     "Expected has_one :#{assoc} to be defined"
    end
  end

  test "has_many setting_preference_activities association is defined" do
    reflection = SettingPreference.reflect_on_association(:setting_preference_activities)

    assert_not_nil reflection
  end

  test "DBSC_BINDING_METHOD_CLASS is SettingPreferenceBindingMethod" do
    assert_equal SettingPreferenceBindingMethod, SettingPreference::DBSC_BINDING_METHOD_CLASS
  end

  test "DBSC_STATUS_CLASS is SettingPreferenceDbscStatus" do
    assert_equal SettingPreferenceDbscStatus, SettingPreference::DBSC_STATUS_CLASS
  end

  test "validates uniqueness of dbsc_session_id" do
    SettingPreference.create!(
      owner_type: "User",
      owner_id: 100,
      dbsc_session_id: "unique_session_id",
    )

    duplicate = build_preference(dbsc_session_id: "unique_session_id")

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:dbsc_session_id]
  end

  test "allows nil dbsc_session_id" do
    preference1 = build_preference(dbsc_session_id: nil)
    preference2 = build_preference(dbsc_session_id: nil, owner_id: 9999)

    assert_predicate preference1, :valid?
    assert_predicate preference2, :valid?
  end

  test "validates uniqueness of owner_id scoped to owner_type" do
    SettingPreference.create!(owner_type: "User", owner_id: 8888)

    duplicate = build_preference(owner_type: "User", owner_id: 8888)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:owner_id]
  end

  test "allows same owner_id with different owner_type at model level" do
    SettingPreference.create!(owner_type: "User", owner_id: 7777)

    different_type = build_preference(owner_type: "Staff", owner_id: 7777)

    assert_predicate different_type, :valid?
  end
end
