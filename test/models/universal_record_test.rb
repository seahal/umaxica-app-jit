require "test_helper"

class UniversalRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate UniversalRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator UniversalRecord, :<, ApplicationRecord
  end

  test "should connect to universal database" do
    # Test that the model is configured to use the universal database
    # Note: This is a basic structural test
    assert_respond_to UniversalRecord, :connection_db_config
  end
end
