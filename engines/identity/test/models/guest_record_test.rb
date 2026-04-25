# typed: false
# frozen_string_literal: true

require "test_helper"

class GuestRecordTest < ActiveSupport::TestCase
  test "is abstract class" do
    assert_predicate GuestRecord, :abstract_class?
  end

  test "inherits from ApplicationRecord" do
    assert_operator GuestRecord, :<, ApplicationRecord
  end

  test "connects to guest database" do
    assert_equal :guest, GuestRecord.connection_db_config.name.to_sym
  end

  test "has correct database configuration" do
    config = GuestRecord.connection_db_config

    assert_not_nil config
  end

  test "connects to correct writing database" do
    writing_config = GuestRecord.connection_specification_name

    assert_not_nil writing_config
  end

  test "is not instantiable as abstract class" do
    assert_raises(NotImplementedError) do
      GuestRecord.new
    end
  end

  test "has database connection methods" do
    assert_respond_to GuestRecord, :connection
    assert_respond_to GuestRecord, :connected?
  end

  test "inherits ActiveRecord methods" do
    assert_respond_to GuestRecord, :find_by_sql
    assert_respond_to GuestRecord, :table_name
    assert_respond_to GuestRecord, :primary_key
  end
end
