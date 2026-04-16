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
#  owner_type               :string
#  revoked_at               :datetime
#  shreddable_at            :datetime
#  token_digest             :binary
#  used_at                  :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  binding_method_id        :bigint           default(0), not null
#  customer_id              :bigint
#  dbsc_session_id          :string
#  dbsc_status_id           :bigint           default(0), not null
#  device_id                :string
#  owner_id                 :bigint
#  public_id                :string           not null
#  replaced_by_id           :bigint
#  staff_id                 :bigint
#  status_id                :bigint           default(0), not null
#  user_id                  :bigint
#
# Indexes
#
#  index_settings_preferences_on_binding_method_id        (binding_method_id)
#  index_settings_preferences_on_customer_id_unique       (customer_id) UNIQUE WHERE (customer_id IS NOT NULL)
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
#  index_settings_preferences_on_staff_id_unique          (staff_id) UNIQUE WHERE (staff_id IS NOT NULL)
#  index_settings_preferences_on_status_id                (status_id)
#  index_settings_preferences_on_token_digest             (token_digest)
#  index_settings_preferences_on_used_at                  (used_at)
#  index_settings_preferences_on_user_id_unique           (user_id) UNIQUE WHERE (user_id IS NOT NULL)
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
      user_id: 1,
      **attrs,
    )
  end

  test "generates public_id on create" do
    preference = SettingPreference.create!(user_id: 1)

    assert_not_nil preference.public_id
    assert_equal 21, preference.public_id.length
  end

  test "requires exactly one owner (user)" do
    preference = SettingPreference.new(user_id: 1)

    assert_predicate preference, :valid?
  end

  test "requires exactly one owner (staff)" do
    preference = SettingPreference.new(staff_id: 1)

    assert_predicate preference, :valid?
  end

  test "requires exactly one owner (customer)" do
    preference = SettingPreference.new(customer_id: 1)

    assert_predicate preference, :valid?
  end

  test "rejects zero owners" do
    preference = SettingPreference.new

    assert_not preference.valid?
    assert_includes preference.errors[:base], "must have exactly one owner (user, staff, or customer)"
  end

  test "rejects multiple owners" do
    preference = SettingPreference.new(user_id: 1, staff_id: 2)

    assert_not preference.valid?
    assert_includes preference.errors[:base], "must have exactly one owner (user, staff, or customer)"
  end

  test "rejects all three owners" do
    preference = SettingPreference.new(user_id: 1, staff_id: 2, customer_id: 3)

    assert_not preference.valid?
    assert_includes preference.errors[:base], "must have exactly one owner (user, staff, or customer)"
  end

  test "enforces unique user_id" do
    SettingPreference.create!(user_id: 999)

    duplicate = SettingPreference.new(user_id: 999)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "enforces unique staff_id" do
    SettingPreference.create!(staff_id: 999)

    duplicate = SettingPreference.new(staff_id: 999)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "enforces unique customer_id" do
    SettingPreference.create!(customer_id: 999)

    duplicate = SettingPreference.new(customer_id: 999)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end

  test "allows same owner_id across different owner types" do
    SettingPreference.create!(user_id: 42)

    assert_nothing_raised do
      SettingPreference.create!(staff_id: 42)
      SettingPreference.create!(customer_id: 42)
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
    past   = SettingPreference.create!(user_id: 2, deletable_at: 1.hour.ago)
    future = SettingPreference.create!(user_id: 3, deletable_at: 1.hour.from_now)

    assert_includes SettingPreference.deletable, past
    assert_not_includes SettingPreference.deletable, future
  end

  test "scope shreddable returns preferences with shreddable_at in the past" do
    past   = SettingPreference.create!(user_id: 4, shreddable_at: 1.hour.ago)
    future = SettingPreference.create!(user_id: 5, shreddable_at: 1.hour.from_now)

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

  test "belongs_to user association is defined" do
    reflection = SettingPreference.reflect_on_association(:user)

    assert_not_nil reflection
  end

  test "belongs_to staff association is defined" do
    reflection = SettingPreference.reflect_on_association(:staff)

    assert_not_nil reflection
  end

  test "belongs_to customer association is defined" do
    reflection = SettingPreference.reflect_on_association(:customer)

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
      user_id: 100,
      dbsc_session_id: "unique_session_id",
    )

    duplicate = build_preference(dbsc_session_id: "unique_session_id")

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:dbsc_session_id]
  end

  test "allows nil dbsc_session_id" do
    preference1 = build_preference(dbsc_session_id: nil)
    preference2 = build_preference(dbsc_session_id: nil, user_id: 9999)

    assert_predicate preference1, :valid?
    assert_predicate preference2, :valid?
  end

  # Backward compatibility tests for polymorphic owner migration
  test "owner_type returns User when user_id is set" do
    preference = SettingPreference.new(user_id: 1)

    assert_equal "User", preference.owner_type
  end

  test "owner_type returns Staff when staff_id is set" do
    preference = SettingPreference.new(staff_id: 1)

    assert_equal "Staff", preference.owner_type
  end

  test "owner_type returns Customer when customer_id is set" do
    preference = SettingPreference.new(customer_id: 1)

    assert_equal "Customer", preference.owner_type
  end

  test "owner_type returns nil when no owner is set" do
    preference = SettingPreference.new

    assert_nil preference.owner_type
  end

  test "owner_id returns user_id when user_id is set" do
    preference = SettingPreference.new(user_id: 42)

    assert_equal 42, preference.owner_id
  end

  test "owner_id returns staff_id when staff_id is set" do
    preference = SettingPreference.new(staff_id: 42)

    assert_equal 42, preference.owner_id
  end

  test "owner_id returns customer_id when customer_id is set" do
    preference = SettingPreference.new(customer_id: 42)

    assert_equal 42, preference.owner_id
  end

  test "owner returns nil when no owner is set" do
    preference = SettingPreference.new

    assert_nil preference.owner
  end

  test "owner= assigns user when given a User" do
    user = User.new(id: 1)
    preference = SettingPreference.new
    preference.owner = user

    assert_equal 1, preference.user_id
    assert_nil preference.staff_id
    assert_nil preference.customer_id
  end

  test "owner= assigns staff when given a Staff" do
    staff = Staff.new(id: 1)
    preference = SettingPreference.new
    preference.owner = staff

    assert_equal 1, preference.staff_id
    assert_nil preference.user_id
    assert_nil preference.customer_id
  end

  test "owner= assigns customer when given a Customer" do
    customer = Customer.new(id: 1)
    preference = SettingPreference.new
    preference.owner = customer

    assert_equal 1, preference.customer_id
    assert_nil preference.user_id
    assert_nil preference.staff_id
  end

  test "owner= clears other owners when reassigned" do
    preference = SettingPreference.new(user_id: 1)
    staff = Staff.new(id: 2)
    preference.owner = staff

    assert_equal 2, preference.staff_id
    assert_nil preference.user_id
    assert_nil preference.customer_id
  end

  test "supports anonymous/bootstrap owner_id of 0" do
    preference = SettingPreference.new(user_id: 0)

    assert_predicate preference, :valid?
    assert_equal 0, preference.owner_id
    assert_equal "User", preference.owner_type
  end
end
