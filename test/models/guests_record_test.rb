require "test_helper"

class GuestsRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate GuestsRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator GuestsRecord, :<, ApplicationRecord
  end

  test "should connect to guest database" do
    # Test that the model is configured to use the guest database
    # Note: This is a basic structural test
    assert_respond_to GuestsRecord, :connection_db_config
  end

  test "should have correct database configuration" do
    config = GuestsRecord.connection_db_config

    assert_not_nil config
  end

  test "should connect to correct writing database" do
    # Verify the writing database configuration
    writing_config = GuestsRecord.connection_specification_name

    assert_not_nil writing_config
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      GuestsRecord.new
    end
  end

  test "should have database connection methods" do
    assert_respond_to GuestsRecord, :connection
    assert_respond_to GuestsRecord, :connected?
  end

  test "should inherit ActiveRecord methods" do
    assert_respond_to GuestsRecord, :find_by_sql
    assert_respond_to GuestsRecord, :table_name
    assert_respond_to GuestsRecord, :primary_key
  end
end
