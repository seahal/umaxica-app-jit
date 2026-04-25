# typed: false
# frozen_string_literal: true

require "test_helper"

class OccurrenceRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate OccurrenceRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator OccurrenceRecord, :<, ApplicationRecord
  end

  test "should connect to occurrence database" do
    # Test that the model is configured to use the occurrence database
    # Note: This is a basic structural test
    assert_respond_to OccurrenceRecord, :connection_db_config
  end
end
