# typed: false
# frozen_string_literal: true

require "test_helper"

# Schema mapping tests for representative models across database families.
# Verifies table_name and connection_db_config.name alignment.
class SchemaMappingTest < ActiveSupport::TestCase
  # Principal database family
  test "User maps to principal database and correct table" do
    assert_equal "users", User.table_name
    assert_equal "principal", User.connection_db_config.name.to_s
  end

  test "UserToken maps to token database and correct table" do
    assert_equal "user_tokens", UserToken.table_name
    assert_equal "token", UserToken.connection_db_config.name.to_s
  end

  test "AppPreference maps to principal database and correct table" do
    assert_equal "app_preferences", AppPreference.table_name
    assert_equal "principal", AppPreference.connection_db_config.name.to_s
  end

  test "UserAuthorizationCode maps to principal database and correct table" do
    assert_equal "user_authorization_codes", UserAuthorizationCode.table_name
    assert_equal "principal", UserAuthorizationCode.connection_db_config.name.to_s
  end

  # Operator database family
  test "Staff maps to operator database and correct table" do
    assert_equal "staffs", Staff.table_name
    assert_equal "operator", Staff.connection_db_config.name.to_s
  end

  test "StaffToken maps to token database and correct table" do
    assert_equal "staff_tokens", StaffToken.table_name
    assert_equal "token", StaffToken.connection_db_config.name.to_s
  end

  test "StaffAuthorizationCode maps to operator database and correct table" do
    assert_equal "staff_authorization_codes", StaffAuthorizationCode.table_name
    assert_equal "operator", StaffAuthorizationCode.connection_db_config.name.to_s
  end

  # Guest database family
  test "Customer maps to guest database and correct table" do
    assert_equal "customers", Customer.table_name
    assert_equal "guest", Customer.connection_db_config.name.to_s
  end

  test "CustomerToken maps to token database and correct table" do
    assert_equal "customer_tokens", CustomerToken.table_name
    assert_equal "token", CustomerToken.connection_db_config.name.to_s
  end

  test "CustomerAuthorizationCode maps to guest database and correct table" do
    assert_equal "customer_authorization_codes", CustomerAuthorizationCode.table_name
    assert_equal "guest", CustomerAuthorizationCode.connection_db_config.name.to_s
  end

  # Occurrence database family
  test "UserOccurrence maps to occurrence database and correct table" do
    assert_equal "user_occurrences", UserOccurrence.table_name
    assert_equal "occurrence", UserOccurrence.connection_db_config.name.to_s
  end

  test "StaffOccurrence maps to occurrence database and correct table" do
    assert_equal "staff_occurrences", StaffOccurrence.table_name
    assert_equal "occurrence", StaffOccurrence.connection_db_config.name.to_s
  end

  # Activity database family
  test "UserActivity maps to activity database and correct table" do
    assert_equal "user_activities", UserActivity.table_name
    assert_equal "activity", UserActivity.connection_db_config.name.to_s
  end

  test "StaffActivity maps to activity database and correct table" do
    assert_equal "staff_activities", StaffActivity.table_name
    assert_equal "activity", StaffActivity.connection_db_config.name.to_s
  end

  test "ScavengerGlobal maps to activity database and correct table" do
    assert_equal "scavenger_globals", ScavengerGlobal.table_name
    assert_equal "activity", ScavengerGlobal.connection_db_config.name.to_s
  end

  # Document/behavior database families
  test "AppDocument maps to publication database and correct table" do
    assert_equal "app_documents", AppDocument.table_name
    assert_equal "publication", AppDocument.connection_db_config.name.to_s
  end

  test "AppDocumentBehavior maps to behavior database and correct table" do
    assert_equal "app_document_behaviors", AppDocumentBehavior.table_name
    assert_equal "behavior", AppDocumentBehavior.connection_db_config.name.to_s
  end
end
