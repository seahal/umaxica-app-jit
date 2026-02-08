# frozen_string_literal: true

require "test_helper"

class ActivityRecordTest < ActiveSupport::TestCase
  test "connects to activity database" do
    config = ActivityRecord.connection_db_config

    assert_equal "activity", config.name
    assert_equal "test_activity_db", config.database
    assert_equal "test_activity_db", ActivityRecord.connection.select_value("SELECT current_database()")
  end

  test "can perform basic write and read via activity model" do
    temp_id = 99_991
    UserAuditLevel.where(id: temp_id).delete_all

    record = UserAuditLevel.create!(id: temp_id)
    assert_equal temp_id, record.id
    assert_equal record, UserAuditLevel.find(temp_id)
  ensure
    UserAuditLevel.where(id: temp_id).delete_all
  end
end
