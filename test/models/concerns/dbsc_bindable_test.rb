# typed: false
# frozen_string_literal: true

require "test_helper"

class DbscBindableTest < ActiveSupport::TestCase
  fixtures :user_token_dbsc_statuses, :user_token_binding_methods
  fixtures :staff_token_dbsc_statuses, :staff_token_binding_methods
  fixtures :customer_token_dbsc_statuses, :customer_token_binding_methods
  fixtures :app_preference_dbsc_statuses, :app_preference_binding_methods
  fixtures :com_preference_dbsc_statuses, :com_preference_binding_methods
  fixtures :org_preference_dbsc_statuses, :org_preference_binding_methods

  def setup
    StaffTokenDbscStatus.ensure_defaults!
    CustomerTokenDbscStatus.ensure_defaults!
    AppPreferenceDbscStatus.ensure_defaults!
    ComPreferenceDbscStatus.ensure_defaults!
    OrgPreferenceDbscStatus.ensure_defaults!

    StaffTokenBindingMethod.ensure_defaults!
    CustomerTokenBindingMethod.ensure_defaults!
    AppPreferenceBindingMethod.ensure_defaults!
    ComPreferenceBindingMethod.ensure_defaults!
    OrgPreferenceBindingMethod.ensure_defaults!
  end

  test "dbsc_status_active? returns true when status is ACTIVE for UserToken" do
    token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE)

    assert_predicate token, :dbsc_status_active?
    assert_not token.dbsc_status_pending?
    assert_not token.dbsc_status_failed?
    assert_not token.dbsc_status_revoke?
    assert_not token.dbsc_status_nothing?
  end

  test "dbsc_status_pending? returns true when status is PENDING for UserToken" do
    token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::PENDING)

    assert_predicate token, :dbsc_status_pending?
    assert_not token.dbsc_status_active?
    assert_not token.dbsc_status_failed?
    assert_not token.dbsc_status_revoke?
    assert_not token.dbsc_status_nothing?
  end

  test "dbsc_status_failed? returns true when status is FAILED for UserToken" do
    token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::FAILED)

    assert_predicate token, :dbsc_status_failed?
    assert_not token.dbsc_status_active?
    assert_not token.dbsc_status_pending?
    assert_not token.dbsc_status_revoke?
    assert_not token.dbsc_status_nothing?
  end

  test "dbsc_status_revoke? returns true when status is REVOKE for UserToken" do
    token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::REVOKE)

    assert_predicate token, :dbsc_status_revoke?
    assert_not token.dbsc_status_active?
    assert_not token.dbsc_status_pending?
    assert_not token.dbsc_status_failed?
    assert_not token.dbsc_status_nothing?
  end

  test "dbsc_status_nothing? returns true when status is NOTHING for UserToken" do
    token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::NOTHING)

    assert_predicate token, :dbsc_status_nothing?
    assert_not token.dbsc_status_active?
    assert_not token.dbsc_status_pending?
    assert_not token.dbsc_status_failed?
    assert_not token.dbsc_status_revoke?
  end

  test "predicates work correctly for StaffToken (Group B - now fixed)" do
    token = StaffToken.new(staff_token_dbsc_status_id: StaffTokenDbscStatus::ACTIVE)

    assert_predicate token, :dbsc_status_active?, "StaffToken should report ACTIVE when status is ACTIVE (value: #{StaffTokenDbscStatus::ACTIVE})"
    assert_not token.dbsc_status_pending?

    token_pending = StaffToken.new(staff_token_dbsc_status_id: StaffTokenDbscStatus::PENDING)

    assert_predicate token_pending, :dbsc_status_pending?,
                     "StaffToken should report PENDING when status is PENDING (value: #{StaffTokenDbscStatus::PENDING})"
    assert_not token_pending.dbsc_status_active?
  end

  test "predicates work correctly for CustomerToken (Group B - now fixed)" do
    token = CustomerToken.new(customer_token_dbsc_status_id: CustomerTokenDbscStatus::ACTIVE)

    assert_predicate token, :dbsc_status_active?, "CustomerToken should report ACTIVE when status is ACTIVE (value: #{CustomerTokenDbscStatus::ACTIVE})"
    assert_not token.dbsc_status_pending?

    token_pending = CustomerToken.new(customer_token_dbsc_status_id: CustomerTokenDbscStatus::PENDING)

    assert_predicate token_pending, :dbsc_status_pending?,
                     "CustomerToken should report PENDING when status is PENDING (value: #{CustomerTokenDbscStatus::PENDING})"
    assert_not token_pending.dbsc_status_active?
  end

  test "predicates work consistently across all 6 model types" do
    # All models now have the same ordering: ACTIVE=1, PENDING=2

    # UserToken (Group A - originally correct)
    user_token = UserToken.new(user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE)

    assert_predicate user_token, :dbsc_status_active?, "UserToken ACTIVE predicate failed"

    # StaffToken (Group B - now fixed)
    staff_token = StaffToken.new(staff_token_dbsc_status_id: StaffTokenDbscStatus::ACTIVE)

    assert_predicate staff_token, :dbsc_status_active?, "StaffToken ACTIVE predicate failed"

    # CustomerToken (Group B - now fixed)
    customer_token = CustomerToken.new(customer_token_dbsc_status_id: CustomerTokenDbscStatus::ACTIVE)

    assert_predicate customer_token, :dbsc_status_active?, "CustomerToken ACTIVE predicate failed"

    # AppPreference (Group A)
    app_pref = AppPreference.new(dbsc_status_id: AppPreferenceDbscStatus::ACTIVE)

    assert_predicate app_pref, :dbsc_status_active?, "AppPreference ACTIVE predicate failed"

    # ComPreference (Group A)
    com_pref = ComPreference.new(dbsc_status_id: ComPreferenceDbscStatus::ACTIVE)

    assert_predicate com_pref, :dbsc_status_active?, "ComPreference ACTIVE predicate failed"

    # OrgPreference (Group B - now fixed)
    org_pref = OrgPreference.new(dbsc_status_id: OrgPreferenceDbscStatus::ACTIVE)

    assert_predicate org_pref, :dbsc_status_active?, "OrgPreference ACTIVE predicate failed"
  end

  test "binding_method predicates work correctly for UserToken" do
    token = UserToken.new(user_token_binding_method_id: UserTokenBindingMethod::DBSC)

    assert_predicate token, :binding_method_dbsc?
    assert_not token.binding_method_nothing?
    assert_not token.binding_method_legacy?
    assert_predicate token, :dbsc_enabled?
  end

  test "dbsc_status_class returns correct class for each model type" do
    assert_equal UserTokenDbscStatus, UserToken.dbsc_status_class
    assert_equal StaffTokenDbscStatus, StaffToken.dbsc_status_class
    assert_equal CustomerTokenDbscStatus, CustomerToken.dbsc_status_class
    assert_equal AppPreferenceDbscStatus, AppPreference.dbsc_status_class
    assert_equal ComPreferenceDbscStatus, ComPreference.dbsc_status_class
    assert_equal OrgPreferenceDbscStatus, OrgPreference.dbsc_status_class
  end

  test "dbsc_binding_method_class returns correct class for each model type" do
    assert_equal UserTokenBindingMethod, UserToken.dbsc_binding_method_class
    assert_equal StaffTokenBindingMethod, StaffToken.dbsc_binding_method_class
    assert_equal CustomerTokenBindingMethod, CustomerToken.dbsc_binding_method_class
    assert_equal AppPreferenceBindingMethod, AppPreference.dbsc_binding_method_class
    assert_equal ComPreferenceBindingMethod, ComPreference.dbsc_binding_method_class
    assert_equal OrgPreferenceBindingMethod, OrgPreference.dbsc_binding_method_class
  end

  test "dbsc_status_attribute_name returns correct attribute name for each model" do
    assert_equal :user_token_dbsc_status_id, UserToken.dbsc_status_attribute_name
    assert_equal :staff_token_dbsc_status_id, StaffToken.dbsc_status_attribute_name
    assert_equal :customer_token_dbsc_status_id, CustomerToken.dbsc_status_attribute_name
    assert_equal :dbsc_status_id, AppPreference.dbsc_status_attribute_name
    assert_equal :dbsc_status_id, ComPreference.dbsc_status_attribute_name
    assert_equal :dbsc_status_id, OrgPreference.dbsc_status_attribute_name
  end

  test "dbsc_binding_method_attribute_name returns correct attribute name for each model" do
    assert_equal :user_token_binding_method_id, UserToken.dbsc_binding_method_attribute_name
    assert_equal :staff_token_binding_method_id, StaffToken.dbsc_binding_method_attribute_name
    assert_equal :customer_token_binding_method_id, CustomerToken.dbsc_binding_method_attribute_name
    assert_equal :binding_method_id, AppPreference.dbsc_binding_method_attribute_name
    assert_equal :binding_method_id, ComPreference.dbsc_binding_method_attribute_name
    assert_equal :binding_method_id, OrgPreference.dbsc_binding_method_attribute_name
  end

  test "constants are unified across all 6 DBSC status models" do
    # This test verifies that all models follow the same convention:
    # NOTHING = 0, ACTIVE = 1 (canonical success), PENDING = 2, FAILED = 3, REVOKE = 4

    models = [
      UserTokenDbscStatus,
      StaffTokenDbscStatus,
      CustomerTokenDbscStatus,
      AppPreferenceDbscStatus,
      ComPreferenceDbscStatus,
      OrgPreferenceDbscStatus,
    ]

    models.each do |model|
      assert_equal 0, model::NOTHING, "#{model.name}::NOTHING should be 0"
      assert_equal 1, model::ACTIVE, "#{model.name}::ACTIVE should be 1 (canonical success)"
      assert_equal 2, model::PENDING, "#{model.name}::PENDING should be 2"
      assert_equal 3, model::FAILED, "#{model.name}::FAILED should be 3"
      assert_equal 4, model::REVOKE, "#{model.name}::REVOKE should be 4"
    end
  end
end
