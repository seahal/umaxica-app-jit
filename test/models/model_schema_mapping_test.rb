# typed: false
# frozen_string_literal: true

require "test_helper"

class ModelSchemaMappingTest < ActiveSupport::TestCase
  test "principal models map to principal database" do
    assert_equal "app_preferences", AppPreference.table_name
    assert_equal "principal", AppPreference.connection_db_config.name
    assert_equal "principal", User.connection_db_config.name
  end

  test "occurrence models map to occurrence database" do
    assert_equal "user_occurrences", UserOccurrence.table_name
    assert_equal "occurrence", UserOccurrence.connection_db_config.name
  end

  test "token models map to token database" do
    assert_equal "user_tokens", UserToken.table_name
    assert_equal "token", UserToken.connection_db_config.name
    assert_equal "staff_tokens", StaffToken.table_name
    assert_equal "token", StaffToken.connection_db_config.name
  end

  test "activity models map to activity database" do
    assert_equal "user_activities", UserActivity.table_name
    assert_equal "activity", UserActivity.connection_db_config.name
    assert_equal "app_preference_activities", AppPreferenceActivity.table_name
    assert_equal "activity", AppPreferenceActivity.connection_db_config.name
  end

  test "behavior models map to behavior database" do
    assert_equal "app_document_behaviors", AppDocumentBehavior.table_name
    assert_equal "behavior", AppDocumentBehavior.connection_db_config.name
    assert_equal "com_document_behaviors", ComDocumentBehavior.table_name
    assert_equal "behavior", ComDocumentBehavior.connection_db_config.name
  end
end
