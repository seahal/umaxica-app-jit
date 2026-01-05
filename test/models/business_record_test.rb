# frozen_string_literal: true

require "test_helper"

class BusinessRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator BusinessRecord, :<, ApplicationRecord
    assert_predicate BusinessRecord, :abstract_class?
  end
end
