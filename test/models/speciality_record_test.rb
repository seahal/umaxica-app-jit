# frozen_string_literal: true

require "test_helper"

class SpecialityRecordTest < ActiveSupport::TestCase
  test "is abstract and inherits from ApplicationRecord" do
    assert_operator SpecialityRecord, :<, ApplicationRecord
    assert_predicate SpecialityRecord, :abstract_class?
  end
end
