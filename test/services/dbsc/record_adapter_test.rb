# typed: false
# frozen_string_literal: true

require "test_helper"

class Dbsc::RecordAdapterTest < ActiveSupport::TestCase
  test "binding_method_attribute delegates to model metadata" do
    assert_equal :binding_method_id, Dbsc::RecordAdapter.binding_method_attribute(AppPreference.new)
    assert_equal :user_token_binding_method_id, Dbsc::RecordAdapter.binding_method_attribute(UserToken.new)
    assert_equal :staff_token_binding_method_id, Dbsc::RecordAdapter.binding_method_attribute(StaffToken.new)
    assert_equal :customer_token_binding_method_id, Dbsc::RecordAdapter.binding_method_attribute(CustomerToken.new)
  end

  test "dbsc_status_attribute delegates to model metadata" do
    assert_equal :dbsc_status_id, Dbsc::RecordAdapter.dbsc_status_attribute(AppPreference.new)
    assert_equal :user_token_dbsc_status_id, Dbsc::RecordAdapter.dbsc_status_attribute(UserToken.new)
    assert_equal :staff_token_dbsc_status_id, Dbsc::RecordAdapter.dbsc_status_attribute(StaffToken.new)
    assert_equal :customer_token_dbsc_status_id, Dbsc::RecordAdapter.dbsc_status_attribute(CustomerToken.new)
  end

  test "binding_method_class returns AppPreferenceBindingMethod" do
    record = AppPreference.new

    result = Dbsc::RecordAdapter.binding_method_class(record)

    assert_equal AppPreferenceBindingMethod, result
  end

  test "binding_method_class returns OrgPreferenceBindingMethod" do
    record = OrgPreference.new

    result = Dbsc::RecordAdapter.binding_method_class(record)

    assert_equal OrgPreferenceBindingMethod, result
  end

  test "binding_method_class returns ComPreferenceBindingMethod" do
    record = ComPreference.new

    result = Dbsc::RecordAdapter.binding_method_class(record)

    assert_equal ComPreferenceBindingMethod, result
  end

  test "binding_method_class returns UserTokenBindingMethod" do
    record = UserToken.new

    result = Dbsc::RecordAdapter.binding_method_class(record)

    assert_equal UserTokenBindingMethod, result
  end

  test "binding_method_class returns StaffTokenBindingMethod" do
    record = StaffToken.new

    result = Dbsc::RecordAdapter.binding_method_class(record)

    assert_equal StaffTokenBindingMethod, result
  end

  test "dbsc_status_class returns AppPreferenceDbscStatus" do
    record = AppPreference.new

    result = Dbsc::RecordAdapter.dbsc_status_class(record)

    assert_equal AppPreferenceDbscStatus, result
  end

  test "binding_method_class raises for unsupported record" do
    record = Struct.new(:id).new(1)

    assert_raises(ArgumentError) { Dbsc::RecordAdapter.binding_method_class(record) }
  end

  test "binding_method_attribute raises for unsupported record" do
    record = Struct.new(:id).new(1)

    assert_raises(ArgumentError) { Dbsc::RecordAdapter.binding_method_attribute(record) }
  end

  test "dbsc_status_attribute raises for unsupported record" do
    record = Struct.new(:id).new(1)

    assert_raises(ArgumentError) { Dbsc::RecordAdapter.dbsc_status_attribute(record) }
  end

  test "normalize_public_key returns nil for blank key" do
    result = Dbsc::RecordAdapter.normalize_public_key(nil)

    assert_nil result
  end

  test "normalize_public_key returns nil for empty string" do
    result = Dbsc::RecordAdapter.normalize_public_key("")

    assert_nil result
  end

  test "normalize_public_key parses JSON string" do
    json = '{"kid":"key1"}'

    result = Dbsc::RecordAdapter.normalize_public_key(json)

    assert_equal "key1", result["kid"]
  end

  test "normalize_public_key handles hash input" do
    hash = { "kid" => "key1" }

    result = Dbsc::RecordAdapter.normalize_public_key(hash)

    assert_equal "key1", result["kid"]
  end

  test "normalize_public_key handles object with to_h" do
    record = Struct.new(:to_h).new({ "kid" => "key1" })

    result = Dbsc::RecordAdapter.normalize_public_key(record)

    assert_equal "key1", result["kid"]
  end
end
