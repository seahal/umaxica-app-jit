require "test_helper"

class CachesRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator CachesRecord, :<, ApplicationRecord
    assert_predicate CachesRecord, :abstract_class?
  end

  test "should have cache database configuration" do
    config = CachesRecord.connection_db_config

    assert_not_nil config
  end

  test "should connect to cache database for writing and reading" do
    assert_respond_to CachesRecord, :connection
    assert_respond_to CachesRecord, :connected?
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      CachesRecord.new
    end
  end

  test "should have proper database connection specification" do
    writing_config = CachesRecord.connection_specification_name

    assert_not_nil writing_config
  end

  test "should inherit all ActiveRecord functionality" do
    assert_respond_to CachesRecord, :table_name
    assert_respond_to CachesRecord, :primary_key
    assert_respond_to CachesRecord, :find_by_sql
    assert_respond_to CachesRecord, :transaction
  end

  test "should be configured for multi-database setup" do
    # Verify this is part of the multi-database architecture
    assert_respond_to CachesRecord, :connection_db_config
    config = CachesRecord.connection_db_config

    assert_not_nil config
  end
end
