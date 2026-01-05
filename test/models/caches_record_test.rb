# frozen_string_literal: true

require "test_helper"

class CacheRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator CacheRecord, :<, ApplicationRecord
    assert_predicate CacheRecord, :abstract_class?
  end

  test "should have cache database configuration" do
    config = CacheRecord.connection_db_config

    assert_not_nil config
  end

  test "should connect to cache database for writing and reading" do
    assert_respond_to CacheRecord, :connection
    assert_respond_to CacheRecord, :connected?
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      CacheRecord.new
    end
  end

  test "should have proper database connection specification" do
    writing_config = CacheRecord.connection_specification_name

    assert_not_nil writing_config
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should inherit all ActiveRecord functionality" do
    assert_respond_to CacheRecord, :table_name
    assert_respond_to CacheRecord, :primary_key
    assert_respond_to CacheRecord, :find_by_sql
    assert_respond_to CacheRecord, :transaction
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should be configured for multi-database setup" do
    # Verify this is part of the multi-database architecture
    assert_respond_to CacheRecord, :connection_db_config
    config = CacheRecord.connection_db_config

    assert_not_nil config
  end
end
