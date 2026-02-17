# frozen_string_literal: true

require "test_helper"

class BehaviorRecordTest < ActiveSupport::TestCase
  test "connects to behavior database" do
    config = BehaviorRecord.connection_db_config

    assert_equal "behavior", config.name
    assert_match(/^test_behavior_db(_\d+)?$/, config.database)
    assert_match(/^test_behavior_db(_\d+)?$/, BehaviorRecord.connection.select_value("SELECT current_database()"))
  end
end
