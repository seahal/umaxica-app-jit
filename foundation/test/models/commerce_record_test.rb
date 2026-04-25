# typed: false
# frozen_string_literal: true

require "test_helper"

class CommerceRecordTest < ActiveSupport::TestCase
  test "is abstract" do
    assert_predicate CommerceRecord, :abstract_class?
  end

  test "connects to commerce database" do
    config = CommerceRecord.connection_db_config

    assert_equal "commerce", config.name
    assert_match(/^test_commerce_db(_\d+)?$/, config.database)
    assert_match(/^test_commerce_db(_\d+)?$/, CommerceRecord.connection.select_value("SELECT current_database()"))
  end

  test "inherits from ApplicationRecord" do
    assert_operator CommerceRecord, :<, ApplicationRecord
  end
end
