# typed: false
# frozen_string_literal: true

require "test_helper"

class OperatorRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate OperatorRecord, :abstract_class?
  end

  test "connects to operator database" do
    config = OperatorRecord.connection_db_config

    assert_equal "operator", config.name
    assert_match(/^test_operator_db(_\d+)?$/, config.database)
    assert_match(/^test_operator_db(_\d+)?$/, OperatorRecord.connection.select_value("SELECT current_database()"))
  end
end
