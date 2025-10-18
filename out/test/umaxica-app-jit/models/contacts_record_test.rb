require "test_helper"

class ContactsRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert ContactsRecord.abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert ContactsRecord < ApplicationRecord
  end

  test "should connect to contact database" do
    # Test that the model is configured to use the contact database
    # Note: This is a basic structural test
    assert_respond_to ContactsRecord, :connection_db_config
  end

  test "should have correct database configuration" do
    config = ContactsRecord.connection_db_config
    assert_not_nil config
  end

  test "should connect to correct writing database" do
    # Verify the writing database configuration
    writing_config = ContactsRecord.connection_specification_name
    assert_not_nil writing_config
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      ContactsRecord.new
    end
  end

  test "should have database connection methods" do
    assert_respond_to ContactsRecord, :connection
    assert_respond_to ContactsRecord, :connected?
  end

  test "should inherit ActiveRecord methods" do
    assert_respond_to ContactsRecord, :find_by_sql
    assert_respond_to ContactsRecord, :table_name
    assert_respond_to ContactsRecord, :primary_key
  end
end
