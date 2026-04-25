# typed: false
# frozen_string_literal: true

require "test_helper"

class SearchRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator SearchRecord, :<, ApplicationRecord
    assert_predicate SearchRecord, :abstract_class?
  end

  test "is configured as a database-backed base class" do
    assert_respond_to SearchRecord, :connection_db_config
  end
end
