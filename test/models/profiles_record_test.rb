# frozen_string_literal: true

require "test_helper"

class ProfileRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator ProfileRecord, :<, ApplicationRecord
    assert_predicate ProfileRecord, :abstract_class?
  end
end
