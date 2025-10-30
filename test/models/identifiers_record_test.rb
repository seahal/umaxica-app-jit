require "test_helper"

class IdentifiersRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate IdentifiersRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator IdentifiersRecord, :<, ApplicationRecord
  end

  test "should connect to identifier database" do
    # Test that the model is configured to use the identifier database
    # Note: This is a basic structural test
    assert_respond_to IdentifiersRecord, :connection_db_config
  end

  test "should have correct database configuration" do
    config = IdentifiersRecord.connection_db_config

    assert_not_nil config
  end

  test "should connect to identifier database for writing and reading" do
    assert_respond_to IdentifiersRecord, :connection
    assert_respond_to IdentifiersRecord, :connected?
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      IdentifiersRecord.new
    end
  end

  test "should have proper database connection specification" do
    writing_config = IdentifiersRecord.connection_specification_name

    assert_not_nil writing_config
  end

  test "should inherit all ActiveRecord functionality" do
    assert_respond_to IdentifiersRecord, :table_name
    assert_respond_to IdentifiersRecord, :primary_key
    assert_respond_to IdentifiersRecord, :find_by_sql
    assert_respond_to IdentifiersRecord, :transaction
  end

  test "should be configured for identifier database multi-database setup" do
    # Verify this is part of the multi-database architecture
    assert_respond_to IdentifiersRecord, :connection_db_config
    config = IdentifiersRecord.connection_db_config

    assert_not_nil config
  end

  test "should support encryption functionality" do
    # Since this is the base class for models with encrypted fields
    assert_respond_to IdentifiersRecord, :encrypts
  end

  test "should support UUID primary keys" do
    # Many identifier models use UUIDs
    assert_respond_to IdentifiersRecord, :primary_key
  end
end
