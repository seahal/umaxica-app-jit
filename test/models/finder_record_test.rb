# typed: false
# frozen_string_literal: true

require "test_helper"

class FinderRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator FinderRecord, :<, ApplicationRecord
    assert_predicate FinderRecord, :abstract_class?
  end

  test "is configured as a database-backed base class" do
    assert_respond_to FinderRecord, :connection_db_config
  end
end
