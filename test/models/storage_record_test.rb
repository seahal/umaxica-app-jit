# frozen_string_literal: true

require "test_helper"

class StorageRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator StorageRecord, :<, ApplicationRecord
    assert_predicate StorageRecord, :abstract_class?
  end
end
