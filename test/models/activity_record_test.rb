# typed: false
# frozen_string_literal: true

require "test_helper"

class ActivityRecordTest < ActiveSupport::TestCase
  test "connects to activity database" do
    config = ActivityRecord.connection_db_config

    assert_equal "activity", config.name
    assert_match(/^test_activity_db(_\d+)?$/, config.database)
    assert_match(/^test_activity_db(_\d+)?$/, ActivityRecord.connection.select_value("SELECT current_database()"))
  end

  test "can perform basic write and read via activity model" do
    temp_id = 99_991
    UserActivityLevel.where(id: temp_id).delete_all

    record = UserActivityLevel.create!(id: temp_id)
    assert_equal temp_id, record.id
    assert_equal record, UserActivityLevel.find(temp_id)
  ensure
    UserActivityLevel.where(id: temp_id).delete_all
  end
end
