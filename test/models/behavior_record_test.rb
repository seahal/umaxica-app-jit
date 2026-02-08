# frozen_string_literal: true

require "test_helper"

class BehaviorRecordTest < ActiveSupport::TestCase
  test "connects to behavior database" do
    config = BehaviorRecord.connection_db_config

    assert_equal "behavior", config.name
    assert_equal "test_behavior_db", config.database
    assert_equal "test_behavior_db", BehaviorRecord.connection.select_value("SELECT current_database()")
  end
end
