# typed: false
# frozen_string_literal: true

require "test_helper"

class ReferenceModelsSchemaMappingTest < ActiveSupport::TestCase
  test "AreaOccurrence maps to expected table and database" do
    assert_equal "area_occurrences", AreaOccurrence.table_name
    assert_equal "occurrence", AreaOccurrence.connection_db_config.name
  end

  test "UserActivity maps to expected table and database" do
    assert_equal "user_activities", UserActivity.table_name
    assert_equal "activity", UserActivity.connection_db_config.name
  end

  test "StaffActivity maps to expected table and database" do
    assert_equal "staff_activities", StaffActivity.table_name
    assert_equal "activity", StaffActivity.connection_db_config.name
  end

  test "AppDocumentBehavior maps to expected table and database" do
    assert_equal "app_document_behaviors", AppDocumentBehavior.table_name
    assert_equal "behavior", AppDocumentBehavior.connection_db_config.name
  end

  test "ScavengerGlobal maps to expected table and database" do
    assert_equal "scavenger_globals", ScavengerGlobal.table_name
    assert_equal "activity", ScavengerGlobal.connection_db_config.name
  end

  test "ScavengerRegional maps to expected table and database" do
    assert_equal "scavenger_regionals", ScavengerRegional.table_name
    assert_equal "behavior", ScavengerRegional.connection_db_config.name
  end
end
