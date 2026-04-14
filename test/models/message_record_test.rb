# typed: false
# frozen_string_literal: true

require "test_helper"

class MessageRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate MessageRecord, :abstract_class?
  end

  test "connects to message database" do
    config = MessageRecord.connection_db_config

    assert_equal "message", config.name
    assert_match(/^test_message_db(_\d+)?$/, config.database)
    assert_match(/^test_message_db(_\d+)?$/, MessageRecord.connection.select_value("SELECT current_database()"))
  end
end
