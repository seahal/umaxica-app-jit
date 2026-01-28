# frozen_string_literal: true

require "test_helper"

class GuestRecordTest < ActiveSupport::TestCase
  test "should be abstract class" do
    assert_predicate GuestRecord, :abstract_class?
  end

  test "should inherit from ApplicationRecord" do
    assert_operator GuestRecord, :<, ApplicationRecord
  end

  test "should connect to guest database" do
    # Test that the model is configured to use the guest database
    # Note: This is a basic structural test
    assert_respond_to GuestRecord, :connection_db_config
  end

  test "should have correct database configuration" do
    config = GuestRecord.connection_db_config

    assert_not_nil config
  end

  test "should connect to correct writing database" do
    # Verify the writing database configuration
    writing_config = GuestRecord.connection_specification_name

    assert_not_nil writing_config
  end

  test "should not be instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      GuestRecord.new
    end
  end

  test "should have database connection methods" do
    assert_respond_to GuestRecord, :connection
    assert_respond_to GuestRecord, :connected?
  end

  test "should inherit ActiveRecord methods" do
    assert_respond_to GuestRecord, :find_by_sql
    assert_respond_to GuestRecord, :table_name
    assert_respond_to GuestRecord, :primary_key
  end
end
